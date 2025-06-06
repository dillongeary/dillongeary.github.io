module Types exposing (..)

import Browser.Dom exposing (Error, Viewport, Element)
import Html exposing (Html)


type ContentShorthand
  = Text_ String
  | Html_ (List (Html Msg))


type ScreenMode
  = Mobile
  | Tablet
  | Desktop
  | BigMobile


type alias Model =
    { viewport : Maybe Int
    , darkmode : Bool
    , positions : Maybe (Int, Int)
    , screen : ScreenMode
    }


type PageSection
  = Career
  | Projects
  | Education


type Msg
  = GotViewport Viewport
  | GotPositions (Result Error (List Element))
  | GetPositionUpdate
  | GetViewportUpdate
  | GoTo PageSection
  | ChangeLightDarkMode
  | NoOp


type ProjectStatus
  = Paused
  | Ongoing
  | Complete


type Skills
  = ProgrammingLanguages
  | Haskell
  | WebDevelopment
  | Research
  | React
  | JavaScript
  | Python
  | Django
  | Java
  | AppDevelopment
  | Kotlin
  | UI
  | Database
  | API