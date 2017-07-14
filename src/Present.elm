module Present
    exposing
        ( titleSlide
        , fullSlide
        , slideWithTitleFull
        , slideWithTitle_50_50
        , fromMarkDown
        , app
        , Styles(..)
        )

{-| This library is a framework to build presentations in Elm.

# Definition
@docs app, Styles

# Slide making functions
@docs titleSlide, fullSlide, slideWithTitleFull, slideWithTitle_50_50, fromMarkDown

-}

import Dict
import Navigation
import Keyboard
import Window
import Html exposing (Html)


{-
   Implementation based on mdgriffith/style-elements
-}

import Style exposing (StyleSheet)


{-
   Slides core modules
-}

import Slides.Model exposing (..)
import Slides.Slides exposing (render)
import Slides.Styles


-- Models


{-| Styles
  You can provide your own styles for the following:

    type Styles
        = None
        | DeckTitle
        | Title
        | Pane
        | Salutation
-}
type alias Styles =
    Slides.Styles.Styles


type alias Presentation msg =
    { past : List (Html msg)
    , current : CurrentSlide msg
    , toGo : List (Html msg)
    }


type alias Model msg =
    { presentation : Presentation msg
    , deck : Deck
    }


type alias Deck =
    List Slide


type Msg
    = Start
    | Next
    | Previous
    | End
    | NewLocation Navigation.Location
    | WindowResizes Window.Size
    | NoOp


type CurrentSlide msg
    = EmptyDeck
    | StartOfDeck
    | EndOfDeck
    | Current (Html msg)



-- update


update : Msg -> Model Msg -> ( Model Msg, Cmd msg )
update msg model =
    case msg of
        Start ->
            ( rewind model, Cmd.none )

        End ->
            ( model, Cmd.none )

        Next ->
            ( next model, Cmd.none )

        Previous ->
            ( prev model, Cmd.none )

        NewLocation l ->
            ( model, Cmd.none )

        WindowResizes windowSize ->
            ( model, Cmd.none )

        NoOp ->
            ( model, Cmd.none )



-- view


view : Model Msg -> Html Msg
view { presentation } =
    case presentation.current of
        EmptyDeck ->
            Html.div [] []

        StartOfDeck ->
            Html.div [] []

        EndOfDeck ->
            Html.div [] []

        Current c ->
            c



-- helpers


{-| Create a title slide.

    titleSlide "This is a title" == slide
-}
titleSlide : Title -> Slide
titleSlide title =
    TitleSlide title


{-| Create a slide with text.

    fullSlide (markdown "## This is a h2" ) == slide
-}
fullSlide : Pane -> Slide
fullSlide pane =
    FullSlide pane


{-| Create a slide with a title and a single box with text content.

    fullSlide "This is the slide title" (fromMarkDown "## This is a h2" ) == slide
-}
slideWithTitleFull : String -> Pane -> Slide
slideWithTitleFull string pane =
    SlideWithTitle string [ ( 1, pane ) ]


{-| Create a slide with a title and a two equally sized boxes with text content.

    fullSlide
      "This is the slide title"
      (fromMarkDown "### This is the left pane" )
      (fromMarkdown "### This is a right pane" )
-}
slideWithTitle_50_50 : String -> Pane -> Pane -> Slide
slideWithTitle_50_50 title left right =
    SlideWithTitle title [ ( 5, left ), ( 5, right ) ]


slideWithTitle_30_70 : String -> Pane -> Pane -> Slide
slideWithTitle_30_70 title left right =
    SlideWithTitle title [ ( 3, left ), ( 7, right ) ]


slideWithoutTitle_50_50 : Pane -> Pane -> Slide
slideWithoutTitle_50_50 left right =
    SlideWithoutTitle [ ( 5, left ), ( 5, right ) ]


slideWithoutTitle_30_70 : Pane -> Pane -> Slide
slideWithoutTitle_30_70 left right =
    SlideWithoutTitle [ ( 3, left ), ( 7, right ) ]


{-| Create content from markdown.

    fromMarkDown "### This is the left content"

-}
fromMarkDown : String -> Pane
fromMarkDown string =
    FromMarkDown string


present : Model Msg -> Model Msg
present model =
    next model


next : Model Msg -> Model Msg
next ({ presentation } as model) =
    case presentation.current of
        EmptyDeck ->
            model

        StartOfDeck ->
            let
                ( newCurrent, newToGo ) =
                    case (pop presentation.toGo) of
                        ( Nothing, l ) ->
                            ( EmptyDeck, l )

                        ( Just cNew, toGoNew ) ->
                            ( Current cNew, toGoNew )

                newPresentation =
                    { presentation
                        | current = newCurrent
                        , toGo = newToGo
                    }
            in
                { model
                    | presentation = newPresentation
                }

        EndOfDeck ->
            model

        Current c ->
            let
                newPast =
                    c :: presentation.past

                ( newCurrent, newToGo ) =
                    case (pop presentation.toGo) of
                        ( Nothing, l ) ->
                            ( EndOfDeck, l )

                        ( Just cNew, toGoNew ) ->
                            ( Current cNew, toGoNew )

                newPresentation =
                    { past = newPast
                    , current = newCurrent
                    , toGo = newToGo
                    }
            in
                { model
                    | presentation = newPresentation
                }


prev : Model Msg -> Model Msg
prev ({ presentation } as model) =
    case presentation.current of
        EmptyDeck ->
            model

        StartOfDeck ->
            model

        EndOfDeck ->
            let
                ( newCurrent, newPast ) =
                    case (pop presentation.past) of
                        ( Nothing, l ) ->
                            ( EmptyDeck, l )

                        ( Just c, l ) ->
                            ( Current c, l )

                newPresentation =
                    { presentation
                        | past = newPast
                        , current = newCurrent
                    }
            in
                { model
                    | presentation = newPresentation
                }

        Current c ->
            let
                newToGo =
                    c :: presentation.toGo

                ( newCurrent, newPast ) =
                    case (pop presentation.past) of
                        ( Nothing, l ) ->
                            ( StartOfDeck, l )

                        ( Just cNew, l ) ->
                            ( Current cNew, l )

                newPresentation =
                    { past = newPast
                    , current = newCurrent
                    , toGo = newToGo
                    }
            in
                { model
                    | presentation = newPresentation
                }


rewind : Model Msg -> Model Msg
rewind ({ presentation } as model) =
    case presentation.current of
        EmptyDeck ->
            model

        StartOfDeck ->
            model

        EndOfDeck ->
            let
                newToGo =
                    (List.reverse presentation.past)

                newPresentation =
                    { past = []
                    , current = StartOfDeck
                    , toGo = newToGo
                    }
            in
                { model
                    | presentation = newPresentation
                }

        Current c ->
            let
                newToGo =
                    (List.reverse presentation.past) ++ (c :: presentation.toGo)

                newPresentation =
                    { past = []
                    , current = StartOfDeck
                    , toGo = newToGo
                    }
            in
                { model
                    | presentation = newPresentation
                }


pop : List a -> ( Maybe a, List a )
pop l =
    case l of
        [] ->
            ( Nothing, [] )

        h :: t ->
            ( Just h, t )


keyCodes : Dict.Dict Int Msg
keyCodes =
    Dict.fromList
        [ ( 36, Start )
          -- home
        , ( 35, End )
          -- end
        , ( 13, Next )
          -- return
        , ( 32, Next )
          -- space
        , ( 39, Next )
          -- arrow right
        , ( 76, Next )
          -- l
        , ( 68, Next )
          -- d
        , ( 37, Previous )
          -- arrow left
        , ( 65, Previous )
          -- a
        , ( 72, Previous )
          -- h
        ]


keyPressDispatcher : Int -> Msg
keyPressDispatcher keyCode =
    Dict.get keyCode keyCodes
        |> Maybe.withDefault NoOp


subscriptions : Model Msg -> Sub Msg
subscriptions model =
    Sub.batch
        [ Keyboard.ups (keyPressDispatcher)
        , Window.resizes WindowResizes
        ]


init : Maybe (StyleSheet Styles variation) -> Deck -> Navigation.Location -> ( Model Msg, Cmd Msg )
init mStylesheet deck location =
    let
        model =
            { deck = deck
            , presentation =
                { past = []
                , current = StartOfDeck
                , toGo = List.map (render mStylesheet) deck
                }
            }
    in
        ( model, Cmd.none )


{-| Create a slidedeck

   slidedeck =
     [ titleSlide "Welcome"
     , fullSlide
         """ # This is a header
         And this should be plain text
         """
     , slideWithTitle_50_50
         "Title of the slide"
         """# Left pane"""
         """# Right pane"""
     ]
       |> app
-}
app : Maybe (StyleSheet Styles variation) -> Deck -> Program Never (Model Msg) Msg
app mStylesheet deck =
    Navigation.program
        NewLocation
        { init = init mStylesheet deck
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



--
