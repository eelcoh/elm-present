module Main exposing (..)

import Present exposing (fromMarkDown, fullSlide, slideWithTitle_50_50, titleSlide)


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
        |> Present.app
