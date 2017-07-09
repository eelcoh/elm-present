module Slides.Slides exposing (..)

import Element exposing (..)
import Element.Attributes exposing (..)
import Html exposing (div)
import List exposing (sum, take)
import Markdown
import Slides.Model exposing (Pane, Pane(..), Slide(..), Title, WeighedPane, Weight)
import Slides.Styles exposing (Styles(..), stylesheet)
import Tuple exposing (first, second)


renderSlide : Slide -> Element Styles variation msg
renderSlide page =
    case page of
        TitleSlide title ->
            deckTitle title

        FullSlide pane ->
            renderPane pane

        SlideWithoutTitle weighedPane ->
            empty

        SlideWithTitle title weighedPane ->
            renderSlideWithTitle title weighedPane

        ThankYou salut ->
            salutation salut


render : Slide -> Html.Html msg
render page =
    renderSlide page
        |> layout stylesheet


renderSlideWithTitle : Title -> List WeighedPane -> Element Styles variation msg
renderSlideWithTitle title weighedPane =
    let
        titleArea =
            area
                { start = ( 0, 0 )
                , width = 10
                , height = 1
                }
                (renderTitle title)

        contentAreas =
            normaliseWeight weighedPane
                |> toAreaPositions
                |> List.map contentArea

        contentArea ( ( c, w ), pc ) =
            area
                { start = ( c, 1 )
                , width = w
                , height = 3
                }
                (renderPane pc)

        areas =
            titleArea :: contentAreas
    in
        grid None
            { columns = [ percent 10, percent 10, percent 10, percent 10, percent 10, percent 10, percent 10, percent 10, percent 10, percent 10 ]
            , rows =
                [ percent 20
                , percent 20
                , percent 20
                , percent 20
                , percent 20
                ]
            }
            []
            areas


renderTitle : String -> Element Styles variation msg
renderTitle t =
    row None
        [ justify, paddingXY 80 20 ]
        [ el Title [] (text t) ]


deckTitle : String -> Element Styles variation msg
deckTitle t =
    row None
        [ verticalCenter, justify, paddingXY 120 40 ]
        [ el DeckTitle [] (text t) ]


salutation : String -> Element Styles variation msg
salutation t =
    row None
        [ verticalCenter, justify, paddingXY 120 40 ]
        [ el Salutation [] (text t) ]


renderPane : Pane -> Element Styles variation msg
renderPane pane =
    case pane of
        FromMarkDown markdownString ->
            let
                htmlContent =
                    Markdown.toHtml Nothing markdownString
                        |> div []
            in
                html htmlContent


normaliseWeight : List ( Weight, a ) -> List ( Weight, a )
normaliseWeight weights =
    let
        maxTen =
            take 10 weights

        allWeights =
            List.map first maxTen

        total =
            sum allWeights

        inPercents =
            List.map (\( w, a ) -> ( w // total, a )) maxTen

        toTens =
            List.map (\( p, a ) -> ( p // 10, a )) inPercents
    in
        case toTens of
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



-- scanl : (a -> b -> b) -> b -> List a -> List b


toAreaPositions : List ( Int, a ) -> List ( ( Int, Int ), a )
toAreaPositions weighedPane =
    let
        f w1 ( s, w0 ) =
            ( (s + w0 + w1), w1 )
    in
        List.map first weighedPane
            |> List.scanl f ( 0, 0 )
            |> List.map2 (flip (,)) (List.map second weighedPane)



{- }
   row [ spacing 10, padding 10 ]
       [ el Box [] empty
       , el Box [] empty
       , el Box [] empty
       ]
-}
