module Present
    exposing
        ( titlePage
        , fullPage
        , pageWithTitleFull
        , pageWithTitle_50_50
        , fromMarkDown
        , app
        )

{-| This library is a framework to build presentations in Elm.

# Definition
@docs app

# Page making functions
@docs titlePage, fullPage, pageWithTitleFull, pageWithTitle_50_50, fromMarkDown

-}

import Dict
import Navigation
import Keyboard
import Window
import Html exposing (Html)


{-
   Main layouting comes from the mdgriffith/style-elements
-}

import Element exposing (Element, viewport)
import Styles exposing (Styles(..))


{-
   Implementation based on mdgriffith/style-elements
-}

import Layouts.Model exposing (..)
import Layouts.Pages exposing (renderPage)


-- Models


type alias Presentation variation msg =
    { past : List (Element Styles variation msg)
    , current : CurrentPage variation msg
    , toGo : List (Element Styles variation msg)
    }


type alias Model variation msg =
    { presentation : Presentation variation msg
    , deck : Deck
    }


type alias Deck =
    List Page


type Msg
    = Start
    | Next
    | Previous
    | End
    | NewLocation Navigation.Location
    | WindowResizes Window.Size
    | NoOp


type CurrentPage variation msg
    = EmptyDeck
    | StartOfDeck
    | EndOfDeck
    | Current (Element Styles variation msg)



-- update


update : Msg -> Model variation Msg -> ( Model variation Msg, Cmd msg )
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


view : Model variation Msg -> Html Msg
view { presentation } =
    case presentation.current of
        EmptyDeck ->
            Html.div [] []

        StartOfDeck ->
            Html.div [] []

        EndOfDeck ->
            Html.div [] []

        Current c ->
            viewport Styles.stylesheet c



-- helpers


{-| Create a title page.

    titlePage "This is a title" == page
-}
titlePage : Title -> Page
titlePage title =
    TitlePage title


{-| Create a page with text.

    fullPage (markdown "## This is a h2" ) == page
-}
fullPage : PageContent -> Page
fullPage pageContent =
    FullPage pageContent


{-| Create a page with a title and a single box with text content.

    fullPage "This is the page title" (fromMarkDown "## This is a h2" ) == page
-}
pageWithTitleFull : String -> PageContent -> Page
pageWithTitleFull string pageContent =
    PageWithTitle string [ ( 1, pageContent ) ]


{-| Create a page with a title and a two equally sized boxes with text content.

    fullPage
      "This is the page title"
      (fromMarkDown "### This is the left content" )
      (fromMarkdown "### This is a right content" )
-}
pageWithTitle_50_50 : String -> PageContent -> PageContent -> Page
pageWithTitle_50_50 title left right =
    PageWithTitle title [ ( 5, left ), ( 5, right ) ]


pageWithTitle_30_70 : String -> PageContent -> PageContent -> Page
pageWithTitle_30_70 title left right =
    PageWithTitle title [ ( 3, left ), ( 7, right ) ]


pageWithoutTitle_50_50 : PageContent -> PageContent -> Page
pageWithoutTitle_50_50 left right =
    PageWithoutTitle [ ( 5, left ), ( 5, right ) ]


pageWithoutTitle_30_70 : PageContent -> PageContent -> Page
pageWithoutTitle_30_70 left right =
    PageWithoutTitle [ ( 3, left ), ( 7, right ) ]


{-| Create content from markdown.

    fromMarkDown "### This is the left content"

-}
fromMarkDown : String -> PageContent
fromMarkDown string =
    FromMarkDown string


present : Model variation Msg -> Model variation Msg
present model =
    next model


next : Model variation Msg -> Model variation Msg
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


prev : Model variation Msg -> Model variation Msg
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


rewind : Model variation Msg -> Model variation Msg
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


subscriptions : Model variation Msg -> Sub Msg
subscriptions model =
    Sub.batch
        [ Keyboard.ups (keyPressDispatcher)
        , Window.resizes WindowResizes
        ]


init : Deck -> Navigation.Location -> ( Model variation Msg, Cmd Msg )
init deck location =
    let
        model =
            { deck = deck
            , presentation =
                { past = []
                , current = StartOfDeck
                , toGo = List.map renderPage deck
                }
            }
    in
        ( model, Cmd.none )


{-| Create a slidedeck

   slidedeck =
     [ titlePage "Welcome"
     , fullPage
         """ # This is a header
         And this should be plain text
         """
     , pageWithTitle_50_50
         "Title of the page"
         """# Left pane"""
         """# Right pane"""
     ]
       |> app
-}
app : Deck -> Program Never (Model variation Msg) Msg
app deck =
    Navigation.program
        NewLocation
        { init = init deck
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



--
