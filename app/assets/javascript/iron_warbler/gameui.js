
$(function() {
  logg('gameui-init')

  const tmp = $('.purses-gameuiW').attr('data-margin-left')

  $('.purses-gameuiW').scrollLeft( tmp );

  // positions-xmulti
  let positions_xmulti = {}
  $('input[type="checkbox"].positions-xmulti').on('change', function () {
    let val = $(this).val()
    logg(val, 'xmulti val?')
    if ($(this).is(":checked")) {
      positions_xmulti[val] = true
    } else {
      delete positions_xmulti[val]
    }
    logg(Object.keys(positions_xmulti).join(','), 'positions_xmulti after event')
    $("form#positionsXmultiSubmit input[type='hidden']#positions_xmulti").val( Object.keys(positions_xmulti).join(',') )
  })


}); // END