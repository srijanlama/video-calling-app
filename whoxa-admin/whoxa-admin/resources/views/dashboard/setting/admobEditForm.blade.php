@extends('dashboard.base')
@section('content')
  <div class="container-fluid">
    <div class="animated fadeIn">
      <div class="row">
        <div class="col-sm-6 col-md-5 col-lg-4 col-xl-6">
          <div class="card">
              <div class="card-header">
               
              </div>
              <div class="card-body">
                  <br>
                  <form method="POST" action="{{ url('/admob-list/update') }}">
                      @csrf
                      @method('GET')
                      
                      <div class="input-group mb-3">
                        <div class="input-group-prepend">
                          <span class="input-group-text">
                           
                              <i class="fa fa-pencil"></i>
                           
                          </span>
                        </div>
                          <input id="id" class="form-control @error('id') is-invalid @enderror" type="text" placeholder="{{ __('Id') }}" name="id" value="{{ $admob['id'] }}" required>
                          @error('id')
                            <span class="invalid-feedback" role="alert">
                                <strong>{{ $message }}</strong>
                            </span>
                        @enderror
                      </div>
                      <button class="btn btn-block btn-success" type="submit">{{ __('Save') }}</button>
                      <a href="{{ route('admob-list') }}" class="btn btn-block btn-primary">{{ __('Return') }}</a> 
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