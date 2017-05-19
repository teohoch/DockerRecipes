/**
 * Created by teohoch on 23/02/17.
 */
// The validator variable is a JSON Object
// The selector variable is a jQuery Object
window.ClientSideValidations.validators.local['client_presence'] = function (element, options) {
    // Your validator code goes in here
    if (/^\s*$/.test(element.val() || '')) {
        return options.message
    }
};