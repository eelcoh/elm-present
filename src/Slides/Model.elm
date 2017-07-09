module Slides.Model exposing (..)


type Slide
    = TitleSlide Title
    | FullSlide Pane
    | SlideWithoutTitle (List WeighedPane)
    | SlideWithTitle Title (List WeighedPane)
    | ThankYou Salut


type alias WeighedPane =
    ( Weight, Pane )


type alias Weight =
    Int


type Pane
    = FromMarkDown String


type alias Title =
    String


type alias Salut =
    String
