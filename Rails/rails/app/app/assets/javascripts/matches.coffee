# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  user_counter = $("#inputs").data("current-users")
  not_tournament = $("#inputs").data("not-tournament")
  used_user_field_ids = []
  used_user_ids = []
  max = 6
  min = 3
  max_users = $("#inputs").data("max-users")
  error_message_user_count = $("#inputs").data("error-message")
  last_id_used = null
  used_user_ids.push($("#match_user_matches_attributes_0_user_id").val())
  if not_tournament and max_users >= 3
    $("#add_purchase_item").show()

  if max_users >= min
    $("#add_purchase_item").show()

  language = $('#matches').data('language')
  $("[id^='matches']").dataTable(
    {
      "language": language, "jQueryUI": true
    })


  field_remover = (target, event) ->
    target.prev('input[type=hidden]').val('1')


    user_value = target.closest('fieldset').find("select").val()
    user_value_location = used_user_ids.indexOf(user_value)
    if user_value_location != -1
      used_user_ids.splice(user_value_location, 1)

    target.closest('fieldset').remove()
    event.preventDefault()

  field_adder = (target, event) ->
    time = new Date().getTime()
    regexp = new RegExp(target.data('id'), 'g')
    data_field = target.data('fields').replace(regexp, time)
    target.before(field_filter(data_field))
    event.preventDefault()
    return time

  field_filter = (fields) ->
    retorno = fields
    for val in used_user_ids
      regex = new RegExp('(<option value="' + val + '">.*?<\/option>)', "g")
      retorno = retorno.replace(regex, "")
    return retorno

  $('#submit_button').click ->
    for id in used_user_field_ids
      $("#match_user_matches_attributes_" + id + "_user_id").prop("disabled", false)
      $("#match_user_matches_attributes_" + id + "_vp").prop("disabled", false)

    if user_counter < 3 or user_counter > 6 or user_counter > max_users
      alert_html = '<div class="container alert alert-danger fade in"> <button class="close" data-dismiss="alert">×</button> <p>' + error_message_user_count + '</p> </div>'
      $(".container").last().before(alert_html)
      event.preventDefault()


  $('form').on 'click', '.remove_fields', (event) ->
    selected = $(this).closest("fieldset").find("select")
    regex = /_(\d*)_/


    if "match_user_matches_attributes_" + last_id_used + "_user_id" == selected.prop("id")
      previous = $(this).closest("fieldset").prev().find("select")
      full_id = previous.prop("id")
      id = regex.exec(full_id)[1]
      unused_val_place = used_user_ids.indexOf(parseInt($("#" + full_id).val()))
      if unused_val_place != -1
        used_user_ids.splice(unused_id_place, 1)
      if (id != "0")
        last_id_used = id
        $("#match_user_matches_attributes_" + id + "_user_id").prop("disabled", false)
        $("#match_user_matches_attributes_" + id + "_vp").prop("disabled", false)
      else
        last_id_used = null

    unused_id_place = used_user_field_ids.indexOf(parseInt(regex.exec(selected.prop("id"))[1]))

    if unused_id_place != -1
      used_user_field_ids.splice(unused_id_place, 1)

    field_remover($(this), event)
    user_counter--
    if user_counter < max
      $("#add_purchase_item").show()

  $('form').on 'click', '.add_fields', (event) ->
    if user_counter <= max or user_counter <= max_users
      if last_id_used != null
        $("#match_user_matches_attributes_" + last_id_used + "_user_id").prop("disabled", true)
        # $("#match_user_matches_attributes_" + last_id_used + "_vp").prop("disabled", true)
        used_user_ids.push($("#match_user_matches_attributes_" + last_id_used + "_user_id").val())
      last_id_used = field_adder($(this), event)
      used_user_field_ids.push(last_id_used)
      user_counter++
    if user_counter == max or user_counter >= max_users
      $(this).hide()

