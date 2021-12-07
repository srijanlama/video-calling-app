@extends('dashboard.base')
@section('content')
  <div class="container-fluid">
    <div class="animated fadeIn">
      <div class="row">
        <div class="col-sm-12 col-md-12 col-lg-8 col-xl-12">
          <div class="card">
              <div class="card-header">
                <i class="fa fa-align-justify"></i>{{ __('Block Users') }}</div>
              <div class="card-body">
                <table id="userstable" class="table table-responsive-sm table-striped table-striped table-bordered" style="width:100%">
                <thead>
                  <tr>
                    <th>Uid</th>
                    <th>Phone Number</th>
                    <th>Username</th>
                    <th>Action</th>
                  </tr>
                </thead>
                <tbody>
                  @foreach($userListArray as $key=>$user)
                  <?php

                  if ($user['disabled']) { ?>
                    <tr>
                      <td>{{ $user['uid'] }}</td>
                      <td>{{ $user['phoneNumber'] }}</td>
                      <td>{{ $user['name'] }}</td>
                      <td>
                      <div class="action-btn">
                          <form action="{{ route('users.block', $user['uid'] ) }}" method="POST">
                              @csrf
                              <?php if ($user['disabled']) { ?>
                                <button class="btn btn-outline-danger" onclick="return confirm('Are you sure Unblock?')" ><i class="fa fa-ban"></i> Blocked</button>
                              <?php } else { ?>
                                <button class="btn btn-outline-success" onclick="return confirm('Are you sure Block?')" ><i class="fa fa-check"></i> Active</button>
                              <?php } ?>
                          </form>
                        
                        </div>
                      </td>
                    </tr>
                    <?php } ?>
                  @endforeach
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
    $('#userstable').DataTable();
} );
</script>
@endsection