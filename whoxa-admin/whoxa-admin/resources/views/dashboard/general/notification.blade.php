@extends('dashboard.base')
@section('content')
  <div class="container-fluid">
    <div class="animated fadeIn">
      <div class="row">

        <div class="col-sm-12 col-md-12 col-lg-8 col-xl-12">
            <div class="card">
               <div class="card-header">
                <i class="fa fa-align-justify"></i>{{ __('Add Notification') }}</div>
                <div class="card-body">
                    <form method="POST" action="{{ url('/add-notification') }}" enctype="multipart/form-data">
                        @csrf
                        <div class="input-group mb-4">
                            <div class="input-group-prepend">
                                <span class="input-group-text">
                                    <i class="fa fa-pencil"></i>
                                </span>
                            </div>
                            <input id="title" class="form-control @error('title') is-invalid @enderror" type="text" placeholder="{{ __('Title') }}" name="title" value="{{ old('title') }}" required>
                            @error('title')
                            <span class="invalid-feedback" role="alert">
                                <strong>{{ $message }}</strong>
                            </span>
                            @enderror
                        </div>
                        <div class="input-group mb-3">
                            <div class="input-group-prepend">
                                <span class="input-group-text">
                                  <i class="fa fa-user"></i>
                                </svg>
                                </span>
                            </div>
                            <input id="pushnotis" class="form-control @error('pushnotis') is-invalid @enderror" type="text" placeholder="{{ __('Notification') }}" name="pushnotis" value="{{ old('pushnotis') }}" required autofocus>
                            @error('name')
                            <span class="invalid-feedback" role="alert">
                                <strong>{{ $message }}</strong>
                            </span>
                            @enderror
                        </div>
                        <div class="input-group mb-3">
                            <div class="input-group-prepend">
                                <span class="input-group-text">
                                <i class="fa fa-user"></i>
                                </span>
                            </div>
                            <input id="uploadimage" class="form-control @error('pushnotis') is-invalid @enderror" type="file" name="image" value="">
                        </div>
                        <button class="btn btn-block btn-success" type="submit">{{ __('Save') }}</button>
                    </form>
                </div>
            </div>
        </div>

        <div class="col-sm-12 col-md-12 col-lg-8 col-xl-12">
          <div class="card">
              <div class="card-header">
                <i class="fa fa-align-justify"></i>{{ __('Notification List') }}</div>
              <div class="card-body">
               <table id ="notification" class="table table-responsive-sm table-striped table-striped table-bordered" style="width:100%">
              <thead>
                <tr>
                  <th>ID</th>
                  <th>Title</th>
                  <th>Notificatin</th>
                  <th>Action</th>
                </tr>
              </thead>
              <tbody>
                <?php if (!empty($pushNotifications)) {
                    $i = 1;
                    foreach ($pushNotifications as $key=>$pushNotification) { ?>
                  <tr>
                    <td>{{$i}}</td>
                    <td>{{$pushNotification['title']}}</td>
                    <td>{{$pushNotification['notification']}}</td>
                    <td>
                      <form action="{{ route('notification-destroy', $key ) }}" method="POST">
                          @csrf
                          <button class="btn btn-outline-info btn-sm" onclick="return confirm('Are you sure Delete?')" ><i class="fa fa-trash"></i>Delete</button>
                      </form>
                    </td>
                  </tr>
               <?php $i++;}
                } ?>
              </tbody>
              </table>
              </div>
          </div>
        </div>
      </div>
    </div>
  </div>
@endsection
@section('javascript')


<script>
$(document).ready(function() {
    $('#notification').DataTable();
} );
</script>
@endsection