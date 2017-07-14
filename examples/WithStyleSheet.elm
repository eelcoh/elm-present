module WithStyleSheet exposing (..)

import Present exposing (fromMarkDown, fullSlide, slideWithTitle_50_50, titleSlide, Styles(..))
import Style
import Style.Border as Border
import Style.Color as Color
import Style.Font as Font


styleSheet =
    Style.stylesheet
        [ style None []
          -- It's handy to have a blank style
        , style DeckTitle
            [ Border.all 1
              -- set all border widths to 1 px.
            , Color.text Color.orange
            , Color.background Color.black
            , Color.border Color.lightGrey
            , Font.typeface [ "courier new", "courier" ]
            , Font.size 40
            , Font.weight 700
            , Font.lineHeight 1.3
              -- line height, given as a ratio of current font size.
            ]
        , style Title
            [ Border.all 1
              -- set all border widths to 1 px.
            , Color.text Color.darkCharcoal
            , Color.background Color.orange
            , Color.border Color.lightGrey
            , Font.typeface [ "courier new", "courier" ]
            , Font.size 40
            , Font.weight 700
            , Font.lineHeight 1.3
              -- line height, given as a ratio of current font size.
            ]
        , style Salutation
            [ Border.all 1
              -- set all border widths to 1 px.
            , Color.text Color.yellow
            , Color.background Color.white
            , Color.border Color.lightGrey
            , Font.typeface [ "courier new", "courier" ]
            , Font.size 40
            , Font.lineHeight 1.3
            , Font.weight 700
              -- line height, given as a ratio of current font size.
            ]
        , style Pane
            [ Border.all 5
            , Border.solid
            , Font.typeface [ "courier new", "courier" ]
            , Font.justify
            , Font.justifyAll
            , Font.wrap
            , Color.text Color.white
            , Color.background Color.darkCharcoal
            , Color.border Color.lightGrey
            ]
        ]


main =
    [ titleSlide "Welcome"
    , fullSlide
        (fromMarkDown
            """
# This is a header
Lorem ipsum dolor sit amet, consectetuer
adipiscing elit. Aenean commodo ligula e
get dolor. Aenean massa. Cum sociis natoque
penatibus et magnis dis parturient montes,
nascetur ridiculus mus. Donec quam felis,
ultricies nec, pellentesque eu, pretium
quis, sem. Nulla consequat massa quis enim.
# Donec pede justo,
* fringilla vel, aliquet
* nec, vulputate eget, arcu. In enim justo,
* rhoncus ut, imperdiet a, venenatis vitae,
* justo.
# Nullam dictum felis
eu pede mollis"""
        )
    , slideWithTitle_50_50
        "Title of the slide"
        (fromMarkDown """
# Left pane
Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula e get dolor. Aenean massa. Cum sociis natoque
penatibus et magnis dis parturient montes,
nascetur ridiculus mus. Donec quam felis,
ultricies nec, pellentesque eu, pretium
quis, sem. Nulla consequat massa quis enim.
# Donec pede justo,
* fringilla vel, aliquet
* nec, vulputate eget, arcu. In enim justo,
* rhoncus ut, imperdiet a, venenatis vitae,
* justo.
# Nullam dictum felis
eu pede mollis
            """)
        (fromMarkDown """
# Right pane
* fringilla vel, aliquet
* nec, vulputate eget, arcu. In enim justo,
* rhoncus ut, imperdiet a, venenatis vitae,
* justo.
# Nullam dictum felis
eu pede mollis
""")
    ]
        |> Present.app (Just styleSheet)
