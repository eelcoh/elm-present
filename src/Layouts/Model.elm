module Layouts.Model exposing (..)


type Page
    = TitlePage Title
    | FullPage PageContent
    | PageWithoutTitle (List WeighedPageContent)
    | PageWithTitle Title (List WeighedPageContent)
    | ThankYou Salut


type alias WeighedPageContent =
    ( Weight, PageContent )


type alias Weight =
    Int


type PageContent
    = FromMarkDown String


type alias Title =
    String


type alias Salut =
    String
