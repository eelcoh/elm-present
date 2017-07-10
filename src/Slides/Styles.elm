module Slides.Styles exposing (..)

import Color exposing (..)
import Style exposing (..)
import Style.Border as Border
import Style.Color as Color
import Style.Font as Font


type Styles
    = None
    | DeckTitle
    | Title
    | Pane
    | Salutation


stylesheet : StyleSheet Styles variation
stylesheet =
    Style.stylesheet
        [ style None []
          -- It's handy to have a blank style
        , style DeckTitle
            [ Border.all 1
              -- set all border widths to 1 px.
            , Color.text Color.orange
            , Color.background Color.white
            , Color.border Color.lightGrey
            , Font.typeface [ "georgia", "times roman", "serif" ]
            , Font.size 40
            , Font.lineHeight 1.3
              -- line height, given as a ratio of current font size.
            ]
        , style Title
            [ Border.all 1
              -- set all border widths to 1 px.
            , Color.text Color.darkCharcoal
            , Color.background Color.white
            , Color.border Color.lightGrey
            , Font.typeface [ "georgia", "times roman", "serif" ]
            , Font.size 25
            , Font.lineHeight 1.3
              -- line height, given as a ratio of current font size.
            ]
        , style DeckTitle
            [ Border.all 1
              -- set all border widths to 1 px.
            , Color.text Color.yellow
            , Color.background Color.white
            , Color.border Color.lightGrey
            , Font.typeface [ "georgia", "times roman", "serif" ]
            , Font.size 10
            , Font.lineHeight 1.3
              -- line height, given as a ratio of current font size.
            ]
        , style Pane
            [ Border.all 5
            , Border.solid
            , Font.typeface [ "helvetica", "arial", "sans-serif" ]
            , Color.text Color.darkCharcoal
            , Color.background Color.white
            , Color.border Color.lightGrey
            ]
        ]
