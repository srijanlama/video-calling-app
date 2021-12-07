@extends('dashboard.base')
@section('content')
    <div class="container-fluid">
      <div class="animated fadeIn">
        <div class="row">
          <div class="col-sm-6 col-md-5 col-lg-4 col-xl-12">
            <div class="card">
                <div class="card-header">
                  <i class="fa fa-align-justify"></i> Group Name: {{ $group['castName'] }}</div>
                <div class="card-body">
                    <h5>Group Desc: {{ $group['castDesc'] }}</h5>
                    <!--<a href="{{ route('users.index') }}" class="btn btn-block btn-primary">{{ __('Return') }}</a>-->
                    <table id="groupMember" class="table table-responsive-sm table-striped table-striped table-bordered" style="width:100%">
                        <thead>
                          <tr>
                            <th>id</th>
                            <th>Member</th>
                            <th>Admin</th>
                            <!--<th>Action</th>-->
                          </tr>
                        </thead>
                        <tbody>
                        <?php
                        $i = 0;
                        if (!empty($group['name'])) { ?>
                        @foreach($group['name'] as $key=>$name) 
                        <?php
                        $i++;
                        if (isset($name)) { ?>
                            <tr>
                                <td>{{ $i }}</td>
                                <td>{{$name}}</td>
                                <td>{{isset($user['name']) ? $user['name']:'' }}</td>
                                <!--<td>-->
                                <!--  <div class="action-btn">-->
                                <!--    <form action="{{ route('group-memberDestroy', $key ) }}" method="POST">-->
                                <!--      @csrf-->
                                <!--      <input type="hidden" name="gname" value="{{$id}}">-->
                                <!--      <button class="btn" onclick="return confirm('Are you sure Delete?')" ><img src="../public/assets/icons/delete.png"></button>-->
                                <!--    </form>-->
                                <!--  </div>-->
                                <!--</td>-->
                            </tr>
                            <?php } ?>
                        @endforeach
                        <?php }
                        ?>
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
    $('#groupMember').DataTable();
} );
</script>
@endsection