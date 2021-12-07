@extends('dashboard.base')
@section('content')
  <div class="container-fluid">
    <div class="animated fadeIn">
      <div class="row">
        <div class="col-sm-6 col-md-5 col-lg-4 col-xl-6">
          <div class="card">
              <div class="card-header">
                <i class="fa fa-align-justify"></i> {{ __('Edit') }} {{ $userName }}</div>
              <div class="card-body">
                  <br>
                  <form method="POST" action="{{route('users_update',$id)}}">
                      @csrf
                      @method('PUT')
                      <div class="input-group mb-3">
                            <div class="input-group-prepend">
                              <span class="input-group-text">
                                <svg class="c-icon c-icon-sm">
                                    <use xlink:href="/assets/icons/coreui/free-symbol-defs.svg#cui-user"></use>
                                </svg>
                              </span>
                          </div>
                          <input id="name" class="form-control" type="text" placeholder="{{ __('Name') }}" name="name" value="{{ $userName }}" required autofocus>
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
                          <input id="phone_number" class="form-control @error('phone_number') is-invalid @enderror" type="text" placeholder="{{ __('Phone Number') }}" name="phoneNumber" value="{{ $phoneNumber }}" required>
                          @error('phone_number')
                            <span class="invalid-feedback" role="alert">
                                <strong>{{ $message }}</strong>
                            </span>
                        @enderror
                      </div>
                      <button class="btn btn-block btn-success" type="submit">{{ __('Save') }}</button>
                      <a href="{{ route('users.index') }}" class="btn btn-block btn-primary">{{ __('Return') }}</a> 
                  </form>
              </div>
          </div>
        </div>
      </div>
    </div>
  </div>
@endsection
@section('javascript')
@endsection