@extends('dashboard.base')
<style>
  body {
  margin: 0;
}
#container {
  max-width: 600px;
  margin: 0 auto;
  text-align: center;
}
.clearfix {
  clear: both;
}
.hidden {
  display: none;
}
#user-info {
  border: none;
  clear: both;
  margin: 0 auto 20px;
  max-width: 400px;
  padding: 10px;
  text-align: left;
}
</style>
@section('content')
  <div class="container-fluid">
    <div class="animated fadeIn">
      <div class="row">
        <div class="col-sm-6 col-md-5 col-lg-4 col-xl-6">
          <div class="card">
              <div class="card-header">
                <i class="fa fa-align-justify"></i> {{ __('Create User') }}</div>
              <div class="card-body">
                  <br>
                  <!-- <form method="POST" action="{{ route('users.store') }}">
                        @csrf
                      <div class="input-group mb-3">
                          <div class="input-group-prepend">
                              <span class="input-group-text">
                                <svg class="c-icon c-icon-sm">
                                    <use xlink:href="/assets/icons/coreui/free-symbol-defs.svg#cui-user"></use>
                                </svg>
                              </span>
                          </div>
                          <input id="name" class="form-control @error('name') is-invalid @enderror" type="text" placeholder="{{ __('Name') }}" name="name" value="{{ old('name') }}" required autofocus>
                          @error('name')
                            <span class="invalid-feedback" role="alert">
                                <strong>{{ $message }}</strong>
                            </span>
                        @enderror
                      </div>
                      <div class="input-group mb-3">
                      <div class="input-group-prepend">
                          <span class="input-group-text">
                            <svg class="c-icon">
                              <use xlink:href="/assets/icons/coreui/free-symbol-defs.svg#cui-envelope-open"></use>
                            </svg>
                          </span>
                        </div>
                          <input id="email" class="form-control @error('email') is-invalid @enderror" type="text" placeholder="{{ __('E-Mail Address') }}" name="email" value="{{ old('email') }}" required>
                            @error('email')
                                <span class="invalid-feedback" role="alert">
                                    <strong>{{ $message }}</strong>
                                </span>
                            @enderror
                      </div>
                      <div class="input-group mb-3">
                        <div class="input-group-prepend">
                          <span class="input-group-text">
                            <svg class="c-icon">
                              <use xlink:href="/assets/icons/coreui/free-symbol-defs.svg#cui-lock-locked"></use>
                            </svg>
                          </span>
                        </div>
                          <input id="password" class="form-control @error('password') is-invalid @enderror" type="password" placeholder="{{ __('Password') }}" name="password" required autocomplete="new-password">
                            @error('password')
                                <span class="invalid-feedback" role="alert">
                                    <strong>{{ $message }}</strong>
                                </span>
                            @enderror
                      </div>
                      <div class="input-group mb-3">
                      <div class="input-group-prepend">
                          <span class="input-group-text">
                            <svg class="c-icon">
                              <use xlink:href="/assets/icons/coreui/free-symbol-defs.svg#cui-lock-locked"></use>
                            </svg>
                          </span>
                        </div>
                          <input id="password-confirm" class="form-control" type="password" placeholder="{{ __('Confirm Password') }}" name="password_confirmation" required autocomplete="new-password">
                            @error('password')
                                <span class="invalid-feedback" role="alert">
                                    <strong>{{ $message }}</strong>
                                </span>
                            @enderror
                      </div>
                      <button class="btn btn-block btn-success" type="submit">{{ __('Save') }}</button>
                      <a href="{{ route('users.index') }}" class="btn btn-block btn-primary">{{ __('Return') }}</a> 
                  </form> -->
                  <!----------------------------------- firebase otp ---------------------->
                  <div class="col-sm-12">
                    <div class="card text-center">
                      <div class="card-header text-white bg-info">
                        Create User
                      </div>
                                    
                      <div class="card-body">
                        <div id="container">
                          <!--<h3>Authentication via Gmail/Phone number</h3>-->
                          <div id="loading">Loading...</div>
                          <div id="loaded" class="hidden">
                            <div id="main">
                              <div id="user-signed-in" class="hidden">
                                <form action="{{ route('users.store') }}" method="post">
                                  {{ csrf_field() }}
                                <div id="user-info">
                                  <div id="phone"></div>
                                    <input type="text" id="mobile_no" name="mobile_no" >
                                  <div class="clearfix"></div>
                                </div>
                                <p>
                                  <button type="submit" id="sign-out">Sign Out</button>
                                </p>
                              </form>
                              </div>
                              <div id="user-signed-out" class="hidden">
                                <div id="firebaseui-spa">
                                  <!--<h3>App:</h3>-->
                                  <div id="firebaseui-container"></div>
                                </div>
                              </div>
                            </div>
                          </div>
                        </div>           
                      </div>
                    </div>
                  </div>
              <!---------------------------------end firebase otp --------------------->
              </div>
          </div>
        </div>
      </div>
    </div>
  </div>
@endsection
@section('javascript')
@endsection