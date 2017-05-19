# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery ->
  pyramidal = false
  ranking = false
  pyramidal_set = false
  ranking_set = false
  max_players = false
  options = null

  language = $('#tournaments').data('language')
  $('#tournaments').dataTable(
    {
      "language": language,"jQueryUI": true
    })



  options_remover = (selector, elements_delete) ->
    for elem in elements_delete
      $('#'+selector+' option[value="'+elem+'"]').remove()

  options_filter = (number_players, board_size) ->
    sel = "pyramidalMode"
    $('#pyramidalMode option').remove()
    $('#tournament_mode').append(options)
    if board_size == 4
      switch
        when (number_players <= 2)
          options_remover(sel, [0, 1, 2, 3, 4, 5])
        when ( 3 <= number_players && number_players <= 4)
          options_remover(sel, [-2,1,2,3,4,5])
        when ( number_players == 5)
          options_remover(sel, [0, 1, 2, 3, 4, 5])
        when ( 6 <= number_players && number_players <= 8)
          options_remover(sel, [-2, 0, 1, 3, 4, 5])
        when (9 <= number_players)
          options_remover(sel, [-2, 0, 3, 4, 5])
    else if board_size == 6
      switch
        when (number_players <= 2)
          options_remover(sel, [0, 1, 2, 3, 4, 5])
        when ( 3 <= number_players && number_players <= 6)
          options_remover(sel, [-2,1,2,3,4,5])
        when ( number_players == 7)
          options_remover(sel, [-2, 0, 1, 3, 4, 5])
        when ( number_players == 8)
          options_remover(sel, [-2, 0, 1, 4, 5])
        when (9 <= number_players)
          options_remover(sel, [-2, 0, 4, 5])

  ranking_setter = ->
    $("#number_players").next().before ($("#general_mode").data("ranking"))
    $("#new_tournament").enableClientSideValidations()
    ranking_set = true

    if (pyramidal_set)
      $("#pyramidalMode").remove()
      pyramidal = false
      pyramidal_set = false

  pyramidal_setter = ->
    if (pyramidal_set)
      $("#pyramidalMode").remove()

    $("#number_players").next().before ($("#general_mode").data("pyramidal"))
    $("#new_tournament").enableClientSideValidations()

    pyramidal_set = true
    options=$('#pyramidalMode option')
    num_players = parseInt($('#tournament_number_players').val(), 10)
    mode = parseInt($("#tournament_board_size").find(":selected").val(),10)

    options_filter(num_players,mode)

    if (ranking_set)
      $("#rankingRounds").remove()
      ranking = false
      ranking_set = false

  mode_setter = ->
    target = $('input:radio[id^="tournament_general_mode"]:checked')

    grandparent = $("#general_mode")

    if target.val() == "-1"
      ranking = true
      pyramidal = false
    else if target.val() == "0"
      pyramidal = true
      ranking = false

    if (!max_players)

      grandparent.next().before ($("#general_mode").data("max-players"))
      max_players = true

      $("#tournament_number_players").bind "blur onchange oninput input", ()->
        if (pyramidal)
          if pyramidal_set
            num_players = parseInt($('#tournament_number_players').val(), 10)
            mode = parseInt($("#tournament_board_size").find(":selected").val(),10)
            options_filter(num_players,mode)
          else
            pyramidal_setter(parent)
        else if (ranking && !ranking_set)
          ranking_setter(parent)
    else
      max_players_set = ($("#tournament_number_players").val()!="")
      # If a value was given for number_players do the following
      if (max_players_set)
        parent = $("#number_players")
        if target.val() == "-1" && !ranking_set
          ranking_setter(parent)
        else if target.val() == "0" && !pyramidal_set
          pyramidal_setter(parent)


  $("[id^='tournament_general_mode_']").on "click", (event)->
    mode_setter()
    $("#" + event.currentTarget.id).prop("checked", true)

  $('#tournament_board_size').on "change", () ->
    if pyramidal_set
      pyramidal_setter()









