<!DOCTYPE html>
<html lang="en">
  <head><meta charset="shift_jis">
    <base href="./">
    
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, shrink-to-fit=no">
    <meta name="description" content="">
    <meta name="author" content="Łukasz Holeczek">
    <meta name="keyword" content="Bootstrap,Admin,Template,Open,Source,jQuery,CSS,HTML,RWD,Dashboard">
    <title>Primocys Admin Panel</title>
    <meta name="msapplication-TileColor" content="#ffffff">
    <meta name="msapplication-TileImage" content="public/assets/favicon/ms-icon-144x144.png">
    <meta name="theme-color" content="#ffffff">
    <!-- Icons-->
    <link href="{{ asset('public/css/free.min.css') }}" rel="stylesheet"> <!-- icons -->
    <!-- <link href="{{ asset('public/css/flag-icon.min.css') }}" rel="stylesheet"> -->
    <!-- Main styles for this application-->
    <link href="{{ asset('public/css/style.css') }}" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.5.2/css/bootstrap.css" rel="stylesheet">
    <link href="https://cdn.datatables.net/1.10.23/css/dataTables.bootstrap4.min.css" rel="stylesheet">
    
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">

    @yield('css')

    <!-- Global site tag (gtag.js) - Google Analytics-->
    <script async="" src="https://www.googletagmanager.com/gtag/js?id=UA-118965717-3"></script>
    <script>
      window.dataLayer = window.dataLayer || [];

      function gtag() {
        dataLayer.push(arguments);
      }
      gtag('js', new Date());
      // Shared ID
      gtag('config', 'UA-118965717-3');
      // Bootstrap ID
      gtag('config', 'UA-118965717-5');
    </script>

    <link href="{{ asset('css/coreui-chartjs.css') }}" rel="stylesheet">
      <!-------------------Firebase OTP--------------------------->
<script src="https://www.gstatic.com/firebasejs/7.21.1/firebase.js"></script>
<script>
    var config = {
        apiKey: "AIzaSyCmEHp1iiUiaTDFolu2h3bRfL9KmbK7s5Q",
        authDomain: "whoxa-2cbdc.firebaseapp.com",
        databaseURL: "https://whoxa-2cbdc-default-rtdb.firebaseio.com",
        projectId: "whoxa-2cbdc",
        storageBucket: "whoxa-2cbdc.appspot.com",
        messagingSenderId: "404469567656",
        appId: "1:404469567656:web:7e381d866aa465bc47f29d",
        measurementId: "G-Y1E82PJ9TC"
     };
    firebase.initializeApp(config);
</script>
<script src="https://cdn.firebase.com/libs/firebaseui/2.3.0/firebaseui.js"></script>
<link type="text/css" rel="stylesheet" href="https://cdn.firebase.com/libs/firebaseui/2.3.0/firebaseui.css" />
  </head>
  <body class="c-app">
    <div class="c-sidebar c-sidebar-dark c-sidebar-fixed c-sidebar-lg-show" id="sidebar">
      @include('dashboard.shared.nav-builder')
      @include('dashboard.shared.header')
      <div class="c-body">
        <main class="c-main">
          @yield('content') 
        </main>
        @include('dashboard.shared.footer')
      </div>
    </div>
    <!-- CoreUI and necessary plugins-->
    <script src="{{ asset('js/coreui.bundle.min.js') }}"></script>
    <script src="{{ asset('js/coreui-utils.js') }}"></script>
    @yield('javascript')
          <!-- firebase otp2 -->

  <script>
    function getUiConfig() {
    return {
        'callbacks': {
            'signInSuccess': function(user, credential, redirectUrl) {
              console.log(user);
            handleSignedInUser(user);
            return false;
            }
        },
      'signInFlow': 'popup',
      'signInOptions': [
            //firebase.auth.GoogleAuthProvider.PROVIDER_ID,
            //firebase.auth.FacebookAuthProvider.PROVIDER_ID,
            //firebase.auth.TwitterAuthProvider.PROVIDER_ID,
            //firebase.auth.GithubAuthProvider.PROVIDER_ID,
            //firebase.auth.EmailAuthProvider.PROVIDER_ID,
            {
                provider: firebase.auth.PhoneAuthProvider.PROVIDER_ID,
                recaptchaParameters: {
                    type: 'image', 
                    size: 'invisible',
                    badge: 'bottomleft' 
                },
                defaultCountry: 'IN', 
                defaultNationalNumber: '1234567890',
                loginHint: '+911234567890'
            }
          ],
      'tosUrl': 'https://www.google.com'
    };
  }

  var ui = new firebaseui.auth.AuthUI(firebase.auth());
  
  var handleSignedInUser = function(user) {
    document.getElementById('user-signed-in').style.display = 'block';
    document.getElementById('user-signed-out').style.display = 'none';
    document.getElementById('phone').textContent = user.phoneNumber;
    document.getElementById('mobile_no').value = user.phoneNumber;
    document.getElementById('sign-out').click();
  };

  var handleSignedOutUser = function() {
    document.getElementById('user-signed-in').style.display = 'none';
    document.getElementById('user-signed-out').style.display = 'block';
    ui.start('#firebaseui-container', getUiConfig());
  };

  firebase.auth().onAuthStateChanged(function(user) {
    document.getElementById('loading').style.display = 'none';
    document.getElementById('loaded').style.display = 'block';
    user ? handleSignedInUser(user) : handleSignedOutUser();
  });

  var initApp = function() {
    document.getElementById('sign-out').addEventListener('click', function() {
    firebase.auth().signOut();
    });
  };
  window.addEventListener('load', initApp);
</script>
<!-- end firebase otp2 -->
  </body>
</html>
