@extends('dashboard.base')
@section('content')
  <div class="container-fluid">
    <div class="animated fadeIn">
      <div class="row">
        <div class="col-sm-12 col-md-12 col-lg-8 col-xl-12">
          <div class="card">
              <div class="card-header">
                <i class="fa fa-align-justify"></i>{{ __(' Admob') }}</div>
              <div class="card-body">
                <!-- <div class="row"> 
                  <a href="{{ route('users.create') }}" class="btn btn-primary m-2">Add User</a>
                </div> -->
               <table id ="groupUsersTable" class="table table-responsive-sm table-striped table-striped table-bordered" style="width:100%">
              <thead>
                <tr>
                  <!--<th>Sr.no</th>-->
                  <th>Id</th>
                  <th>Action</th>
                </tr>
              </thead>
              <tbody>
                <?php 
                $i = 0;
                $i++; ?>
                  <tr>
                    <!--<td>{{ $i }}</td>-->
                    <td>{{ $admob['id'] }}</td>
                    <!-- <td>
                    <div class="action-btn">
                      {{ $admob['status'] }}
                     
                    </div>
                    </td> -->
                    <td>
                      <div class="action-btn" style="display: inline-flex;">

                        <a href="{{ url('/admob-list/edit') }}" class="btn btn-outline-info btn-sm"><i class="fa fa-pencil-square-o"></i> Edit</a>

                      </div>
                    </td>
                  </tr>
               
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

<!--<script>-->
<!--  $(document).on('click', '.active_deactive', function(){-->
<!--    var id = $(this).data('i');-->
<!--    var is_value = $(this).data('is_value');-->
<!--     $.ajax({-->
<!--           url: '/status_on_off_ajax',-->
<!--           method:"GET",-->
<!--           dataType: "json",-->
<!--           data:{id:id,is_value:is_value},-->
<!--           success:function(data)-->
<!--           {-->
<!--                console.log(data.success)-->
<!--           }-->
<!--      });-->
<!--  });-->
<!--</script>-->

@endsection