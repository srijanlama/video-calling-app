@extends('dashboard.base')
@section('content')
  <div class="container-fluid">
    <div class="animated fadeIn">
      <div class="row">
        <div class="col-sm-12 col-md-12 col-lg-8 col-xl-12 switch" style="display: inline-flex;">
          <!-- <div class="card"> -->
             
                {{ __(' Admob Setting') }} 
                <label class="c-switch c-switch-label c-switch-pill c-switch-primary">
                  <?php 
                    if($admob['status'] == "on"){
                      $checked = 'checked';
                    }else{
                        $checked = 'unchecked';
                    }
                   ?> 
                  <input type="checkbox"  <?php echo $checked; ?> class="active_deactive c-switch-input" 
                  data-is_value="<?php echo $admob['status']; ?>" data-i="<?php echo $admob['id'] ?>"  ><span class="c-switch-slider" data-checked="On" data-unchecked="Off"></span>
               </label>
             
          <!-- </div> -->
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

<script>
  $(document).on('click', '.active_deactive', function(){
    var id = $(this).data('i');
    var is_value = $(this).data('is_value');
     $.ajax({
           url: '/whoxa-admin/status_on_off_ajax',
           method:"GET",
           dataType: "json",
           data:{id:id,is_value:is_value},
           success:function(data)
           {
                console.log(data.success)
           }
      });
  });
</script>

@endsection