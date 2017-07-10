module Main exposing (..)

import Present exposing (fromMarkDown, fullSlide, slideWithTitle_50_50, titleSlide)


main =
    [ titleSlide "Welcome"
    , fullSlide
        (fromMarkDown
            """ # This is a header
      And this should be plain text
      """
        )
    , slideWithTitle_50_50
        "Title of the slide"
        (fromMarkDown """# Left pane""")
        (fromMarkDown """# Right pane""")
    ]
        |> Present.app
