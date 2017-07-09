module Layouts.Pages exposing (..)

import Element exposing (..)
import Element.Attributes exposing (..)
import Html exposing (div)
import Layouts.Model exposing (Page(..), PageContent, PageContent(..), Title, WeighedPageContent, Weight)
import List exposing (sum, take)
import Markdown
import Styles exposing (Styles(..))
import Tuple exposing (first, second)


renderPage : Page -> Element Styles variation msg
renderPage page =
    case page of
        TitlePage title ->
            deckTitle title

        FullPage pageContent ->
            renderPageContent pageContent

        PageWithoutTitle weighedContents ->
            empty

        PageWithTitle title weighedContents ->
            renderPageWithTitle title weighedContents

        ThankYou salut ->
            salutation salut


renderPageWithTitle : Title -> List WeighedPageContent -> Element Styles variation msg
renderPageWithTitle title weighedContents =
    let
        titleArea =
            area
                { start = ( 0, 0 )
                , width = 10
                , height = 1
                }
                (renderTitle title)

        contentAreas =
            normaliseWeight weighedContents
                |> toAreaPositions
                |> List.map contentArea

        contentArea ( ( c, w ), pc ) =
            area
                { start = ( c, 1 )
                , width = w
                , height = 3
                }
                (renderPageContent pc)

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


renderPageContent : PageContent -> Element Styles variation msg
renderPageContent pageContent =
    case pageContent of
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
toAreaPositions weighedContents =
    let
        f w1 ( s, w0 ) =
            ( (s + w0 + w1), w1 )
    in
        List.map first weighedContents
            |> List.scanl f ( 0, 0 )
            |> List.map2 (flip (,)) (List.map second weighedContents)



{- }
   row [ spacing 10, padding 10 ]
       [ el Box [] empty
       , el Box [] empty
       , el Box [] empty
       ]
-}
