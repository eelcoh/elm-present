module Slides.Slides exposing (render)

import Element exposing (..)
import Element.Attributes exposing (..)
import Html exposing (div)
import List exposing (sum, take)
import Markdown
import Slides.Model exposing (Pane, Pane(..), Slide(..), Title, WeighedPane, Weight)
import Slides.Styles as Default exposing (Styles(..))
import Tuple exposing (first, second)
import Style exposing (..)


render : Maybe (StyleSheet Styles variation) -> Slide -> Html.Html msg
render mStylesheet slide =
    let
        ssheet =
            Maybe.withDefault Default.stylesheet mStylesheet
    in
        renderSlide slide
            |> layout ssheet


renderSlide : Slide -> Element Styles variation msg
renderSlide slide =
    case slide of
        TitleSlide title ->
            deckTitle title

        FullSlide pane ->
            renderOnGrid Nothing [ ( 1, pane ) ]

        SlideWithoutTitle weighedPane ->
            renderOnGrid Nothing weighedPane

        SlideWithTitle title weighedPane ->
            renderOnGrid (Just title) weighedPane

        ThankYou salut ->
            salutation salut


renderOnGrid : Maybe Title -> List WeighedPane -> Element Styles variation msg
renderOnGrid mTitle weighedPane =
    let
        mTitleArea =
            Maybe.map titleArea mTitle

        titleArea title =
            area
                { start = ( 0, 0 )
                , width = 10
                , height = 1
                }
                (renderTitle title)

        startY =
            Maybe.map (\_ -> 1) mTitleArea
                |> Maybe.withDefault 0

        panes =
            normaliseWeight weighedPane
                |> toAreaPositions
                |> List.map paneArea

        paneArea ( ( c, w ), pc ) =
            area
                { start = ( c, startY )
                , width = w
                , height = (4 - startY)
                }
                (renderPane pc)

        areas =
            case mTitleArea of
                Just title ->
                    title :: panes

                Nothing ->
                    panes
    in
        grid None
            { columns = List.repeat 10 (percent 10)
            , rows = List.repeat 5 (percent 20)
            }
            []
            areas


renderTitle : String -> Element Styles variation msg
renderTitle t =
    row None
        [ width (percent 100), justify, paddingXY 40 20 ]
        [ el Title [] (text t) ]


deckTitle : String -> Element Styles variation msg
deckTitle t =
    row None
        [ width (percent 100), height (percent 100), verticalCenter, justify, paddingXY 120 40 ]
        [ el DeckTitle [] (text t) ]


salutation : String -> Element Styles variation msg
salutation t =
    row None
        [ width (percent 100), verticalCenter, justify, paddingXY 120 40 ]
        [ el Salutation [] (text t) ]


renderPane : Pane -> Element Styles variation msg
renderPane pane =
    let
        paneContent =
            case pane of
                FromMarkDown markdownString ->
                    let
                        htmlContent =
                            Markdown.toHtml Nothing markdownString
                                |> div []
                    in
                        html htmlContent
    in
        el Pane [ spacing 40, padding 40, width (percent 100) ] paneContent


normaliseWeight : List ( Weight, a ) -> List ( Weight, a )
normaliseWeight weights =
    let
        maxTen =
            take 10 weights

        total =
            List.map first maxTen
                |> sum

        inPercents =
            List.map (\( w, a ) -> ( (w * 100) // total, a )) maxTen

        inPerTens =
            List.map (\( p, a ) -> ( p // 10, a )) inPercents
    in
        case inPerTens of
            [] ->
                []

            ( w, a ) :: rest ->
                let
                    restSize =
                        List.map first rest
                            |> sum

                    firstSize =
                        10 - restSize
                in
                    ( firstSize, a ) :: rest


toAreaPositions : List ( Int, a ) -> List ( ( Int, Int ), a )
toAreaPositions weighedPanes =
    List.map first weighedPanes
        |> List.scanl (+) 0
        |> List.map2 (\( w, a ) s -> ( ( s, w ), a )) weighedPanes
