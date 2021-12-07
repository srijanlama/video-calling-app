@extends('dashboard.base')
@section('content')
  <div class="container-fluid">
    <div class="animated fadeIn">
      <div class="row">
        <div class="col-sm-12 col-md-12 col-lg-8 col-xl-12">
          <div class="card">
              <div class="card-header">
                <i class="fa fa-align-justify"></i>{{ __('Users') }}</div>
              <div class="card-body">
                <div class="row"> 
                  <a href="{{ route('users.create') }}" class="btn btn-primary m-2">{{ __('Add User') }}</a>
                </div>
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
                  <?php //echo '<pre>';print_r($user); die; ?>
                    <tr>
                      <td>{{ $user['uid'] }}</td>
                      <td>{{ $user['phoneNumber'] }}</td>
                      <td>{{ $user['name'] }}</td>
                      <td>
                      <div class="action-btn" style="display: inline-flex;">
                        <a href="{{ url('/users/' . $user['uid']) }}" class="btn btn-outline-warning btn-sm"><span class="fa fa-eye"></span></a>
                        <a href="{{ url('/users/' . $user['uid'] . '/edit') }}" class="btn btn-outline-info btn-sm"><i class="fa fa-pencil-square-o"></i> Edit</a>
                        @if( $you->localId !== $user['uid'] )
                          <!-- <form action="{{ route('users.destroy', $user['uid'] ) }}" method="POST">
                              @method('DELETE')
                              @csrf
                              <button class="btn btn-danger btn-sm" onclick="return confirm('Are you sure Delete?')" ><i class="fa fa-trash-o"></i>Delete</button>
                          </form> -->
                        @endif
                        @if( $you->localId !== $user['uid'] )
                          <form action="{{ route('users.block', $user['uid'] ) }}" method="POST">
                              @csrf
                              <?php if ($user['disabled']) { ?>
                                <button class="btn btn-outline-danger btn-sm" onclick="return confirm('Are you sure Unblock?')" ><span class="fa fa-power-off"></span> DeActivate</button>
                              <?php } else { ?>
                                <button class="btn btn-outline-success btn-sm" onclick="return confirm('Are you sure block?')" ><span class="fa fa-key"></span> Activate</button>
                              <?php } ?>
                          </form>
                        @endif
                        </div>
                      </td>
                    </tr>
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