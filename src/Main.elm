module Main exposing (..)

import Browser exposing (document)
import Browser.Dom exposing (getViewport, Viewport, getElement, setViewport)

import Html exposing (Html, div, text, h1, a, i)
import Html.Attributes exposing (style, id, href, class)
import Html.Events exposing (onClick)

import Platform.Cmd exposing (none)

import Task exposing (perform, sequence, attempt, succeed, andThen)

import Time exposing (every)

import HtmlComponents exposing (flexRow, flexCol, timeLine, timeLineBox, projectBox)
import Types exposing (Msg(..), Model, ProjectStatus(..), Skills(..), ContentShorthand, PageSection(..), ScreenMode(..))
import ColorScheme exposing (getGetColor, Color(..))
import Paragraphs exposing (ampereDesc, blockellDesc, sotonDesc, activePointsDesc, internshipDesc, kingJohnDesc)


-- MAIN


main = document
    { init = init
    , update = update
    , view = (viewToDocument view)
    , subscriptions = subscriptions
    }


-- DOCUMENT


type alias DocumentType =
    { title : String
    , body : List (Html Msg)
    }

viewToDocument : (Model -> Html Msg) -> Model -> DocumentType
viewToDocument v m = { title = "Webpage", body = [ v m ] }


-- MODEL


init : () -> (Model, Cmd Msg)
init _ =
    (
    { viewport = Nothing
    , darkmode = True
    , positions = Nothing
    , screen = Desktop
    }
    , none
    )


-- UPDATE


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        GotViewport viewport -> ({ model | viewport = Just (round viewport.viewport.y), screen = if viewport.viewport.width > 1450 then Desktop else if viewport.viewport.width > 1300 then Tablet else if viewport.viewport.width > 600 then BigMobile else Mobile }, none)
        GotPositions result -> case result of
            Ok [eProject, eEducation] -> ({ model | positions = Just (round eProject.element.y, round eEducation.element.y)}, none)
            _ -> (model, none)
        GetPositionUpdate -> ( model
                     , attempt GotPositions (sequence [ getElement "HProject", getElement "HEducation" ] )
                     )
        GetViewportUpdate -> ( model
                     , perform GotViewport getViewport
                     )
        GoTo section -> ( model
                        , case section of
                            Career -> perform (\_ -> NoOp) (setViewport 0 0)
                            Projects -> case model.positions of
                              Nothing -> none
                              Just (i,_) -> perform (\_ -> NoOp) (setViewport 0 (toFloat (i - 181)))
                            Education -> case model.positions of
                              Nothing -> none
                              Just (_,i) -> perform (\_ -> NoOp) (setViewport 0 (toFloat (i - 181)))
                        )
        ChangeLightDarkMode -> ({model | darkmode = not model.darkmode}, none)
        NoOp -> ( model, none )


-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ = Sub.batch  [every 50 (\_ -> GetPositionUpdate), every 50 (\_ -> GetViewportUpdate)]


-- VIEW


getCurrentSection : Model -> PageSection
getCurrentSection model =
  let
    currentYScroll =
      case model.viewport of
        Nothing -> 0
        Just i -> i
    (projectsPosition, educationPosition) =
      case model.positions of
        Nothing -> (100,100)
        Just i -> i
  in
  case ((currentYScroll+381) >= projectsPosition, ((currentYScroll+381) >= educationPosition)) of
    (False, False) -> Career
    (True, False) -> Projects
    (True, True) -> Education
    _ -> Education



view : Model -> Html Msg
view model = let currentSection = getCurrentSection model
                 getColor = getGetColor model
                 columnPadding = [style "padding" (if (model.screen == Mobile || model.screen == BigMobile) then "5rem 1rem" else "10rem 5rem"), style "box-sizing" "border-box" ]
                 pageLink = [ style "color" (getColor Overlay), style "cursor" "pointer", style "transition" "font-size 0.5s, color 0.5s, font-weight 0.5s"]
                 activePageLink = [ style "color" (getColor Flamingo), style "font-size" "3em", style "font-weight" "bold", style "font-style" "italic", style "transition" "font-size 0.5s, color 0.5s, font-weight 0.5s"]
                 contentBox = style "minHeight" (if (model.screen == Mobile || model.screen == BigMobile) then "0" else "calc(100vh - 20rem)")
                 headingAlign = if (model.screen == Mobile || model.screen == BigMobile) then "center" else "flex-end"
                 headingBlock = if (model.screen == Mobile || model.screen == BigMobile) then "static" else "sticky"
  in
  div [style "color" (getColor Text), style "background-color" (getColor Background), style "font-family" "sans-serif"] [
  div ((if (model.screen == Mobile || model.screen == BigMobile )then [] else [ style "display" "flex", style "flex-direction" "row", style "justify-content" "center"]) ++ [style "min-height" "100vh", style "max-width" "1600px", style "margin" "auto"])
    [ flexCol (columnPadding ++ [style "flex" "1", style "align-items" headingAlign, style "justify-content" "center", style "position" headingBlock, style "top" "0"] ++ (if model.screen == Tablet then [style "padding-right" "0"] else []) ++ (if (model.screen == Mobile || model.screen == BigMobile) then [style "padding-bottom" "0", style "gap" "3rem"] else [style "height" "100vh"]))
      (
        [
         h1 [ style "font-size" (if model.screen == Desktop then "5rem" else "3.5rem"), style "text-align" "center"] [ text "Dillon Geary" ]
        ] ++ (
        if (model.screen == Mobile || model.screen == BigMobile)
        then []
        else
          [ a
            (
              [ onClick (GoTo Career)
              ] ++ if (currentSection == Career) then activePageLink else pageLink
            )
            [ text "Career" ]
          , a
            (
              [ onClick (GoTo Projects)
              ] ++ if (currentSection == Projects) then activePageLink else pageLink
            )
            [ text "Projects" ]
          , a
            (
              [ onClick (GoTo Education)
              ] ++ if (currentSection == Education) then activePageLink else pageLink
            )
            [ text "Education" ]
          ]
        )
      )
    , flexCol (columnPadding ++ [style "align-items" "flex-start", style "gap" "10rem"] ++ (if (model.screen == Mobile || model.screen == BigMobile) then [] else [style "width" "800px"]))
      [ div [contentBox]
        [ h1 [id "HCareer"] [ text "Career" ]
        , timeLine (model.screen == Mobile || model.screen == BigMobile)
          [ timeLineBox
              False
              (model.screen /= Mobile )
              "Web Developer"
              "Ampere Analysis"
              "2024 - Current"
              [ WebDevelopment, React, Django, UI, Database, API]
              ampereDesc
          , timeLineBox
              True
              (model.screen /= Mobile )
              "Software Engineer - Intern"
              "University of Southampton"
              "2023"
              [ AppDevelopment, Kotlin, Research, UI]
              internshipDesc
          ]
        ]
      , div [contentBox]
        [ h1 [id "HProject"] [ text "Projects" ]
        , timeLine (model.screen == Mobile || model.screen == BigMobile)
          [ projectBox
              (model.screen /= Mobile )
              "A Block-Based Visual Programming Language"
              Paused
              "2022 - 2024"
              [ ProgrammingLanguages, Haskell, WebDevelopment, Research ]
              blockellDesc
          , projectBox
              (model.screen /= Mobile )
              "Web-Based Medical Data Dashboard"
              Complete
              "2023"
              [ WebDevelopment, React, UI, API ]
              activePointsDesc
          ]
        ]
      , div [contentBox]
        [ h1 [id "HEducation"] [ text "Education" ]
        , timeLine (model.screen == Mobile || model.screen == BigMobile)
          [ timeLineBox
              False
              (model.screen /= Mobile )
              "University of Southampton"
              "First Class MEng Computer Science"
              "2020 - 2024"
              []
              sotonDesc
          , timeLineBox
              True
              (model.screen /= Mobile )
              "The King John School and Sixth Form"
              ""
              "2013 - 2020"
              []
              kingJohnDesc
          ]
        ]
      ]
    , div
      [ style "position" (if (model.screen == Desktop || model.screen == Tablet) then "fixed" else "absolute")
      , style "top" "0"
      , style "right" "0"
      , style "margin" "1.5rem 2rem"
      , style "cursor" "pointer"
      , onClick ChangeLightDarkMode
      ]
      [ i (if model.darkmode then [class "bi", class "bi-brightness-high-fill"] else [class "bi", class "bi-moon-fill"]) [] ]
    ]
    , flexRow
      [ style "justify-content" "space-evenly"
      , style "gap" "1rem"
      , style "background-color" (getColor BackgroundAccent)
      , style "padding" "0.5rem"
      , style "box-sizing" "border-box"
      , style "flex-wrap" "wrap"
      ]
      [ div [] [text "Built and powered by ", a [href "https://elm-lang.org/", style "color" (getColor Overlay)] [text "Elm"]]
      , div [] [text "Theme by ", a [href "https://catppuccin.com/", style "color" (getColor Overlay)] [ text "Catppuccin"]]
      , div [] [text "Source code on ", a [href "https://github.com/dillongeary/dillongeary.github.io", style "color" (getColor Overlay)] [ text "GitHub"]]
      ]
    ]
