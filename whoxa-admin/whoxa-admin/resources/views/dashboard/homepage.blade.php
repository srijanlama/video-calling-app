@extends('dashboard.base')

@section('content')

    <div class="container-fluid">
        <div class="fade-in">
            <div class="row">
                <div class="col-sm-6 col-lg-3">
                    <div class="card text-white bg-primary">
                        <div class="card-body pb-0">
                            <div class="btn-group float-right">
                                
                                <div class="dropdown-menu dropdown-menu-right"><a class="dropdown-item"
                                        href="#">Action</a><a class="dropdown-item" href="#">Another action</a><a
                                        class="dropdown-item" href="#">Something else here</a></div>
                            </div>
                            <div class="text-value-lg"><?php echo isset($videoCount) ? $videoCount : ''; ?></div>
                            <div>Video Calls</div>
                        </div>
                        <div class="c-chart-wrapper mt-3 mx-3" style="height:5px;">
                            <canvas class="chart" id="card-chart2" height="5"></canvas>
                        </div>
                    </div>
                </div>
                <!-- /.col-->
                <div class="col-sm-6 col-lg-3">
                    <div class="card text-white bg-info">
                        <div class="card-body pb-0">
                            
                            <div class="text-value-lg"><?php echo isset($voiceCount) ? $voiceCount : ''; ?></div>
                            <div>Audio Calls</div>
                        </div>
                        <div class="c-chart-wrapper mt-3 mx-3" style="height:5px;">
                            <canvas class="chart" id="card-chart2" height="5"></canvas>
                        </div>
                    </div>
                </div>
                <!-- /.col-->
                <div class="col-sm-6 col-lg-3">
                    <div class="card text-white bg-warning">
                        <div class="card-body pb-0">
                            <div class="btn-group float-right">
                                
                                <div class="dropdown-menu dropdown-menu-right"><a class="dropdown-item"
                                        href="#">Action</a><a class="dropdown-item" href="#">Another action</a><a
                                        class="dropdown-item" href="#">Something else here</a></div>
                            </div>
                            <div class="text-value-lg"><?php echo isset($broadcastCount) ? $broadcastCount :
                                0; ?></div>
                            <div>Broadcast Group Count</div>
                        </div>
                       <div class="c-chart-wrapper mt-3 mx-3" style="height:5px;">
                            <canvas class="chart" id="card-chart2" height="5"></canvas>
                        </div>
                    </div>
                </div>
                <!-- /.col-->
                <div class="col-sm-6 col-lg-3">
                    <div class="card text-white bg-danger">
                        <div class="card-body pb-0">
                            <div class="btn-group float-right">
                               
                                <div class="dropdown-menu dropdown-menu-right"><a class="dropdown-item"
                                        href="#">Action</a><a class="dropdown-item" href="#">Another action</a><a
                                        class="dropdown-item" href="#">Something else here</a></div>
                            </div>
                            <div class="text-value-lg"><?php echo isset($groupCount) ? $groupCount : 0; ?></div>
                            <div>Group Count</div>
                        </div>
                        <div class="c-chart-wrapper mt-3 mx-3" style="height:5px;">
                            <canvas class="chart" id="card-chart2" height="5"></canvas>
                        </div>
                    </div>
                </div>
                <!-- /.col-->
            </div>
            <!-- /.row-->
            <div class="card">
                <div class="card-body">
                    <div class="row">
                        <div class="col-sm-5">
                            <h4 class="card-title mb-0">Traffic</h4>
                            <div class="small text-muted">Year 2021</div>
                        </div>
                        <!-- /.col-->
                        <div class="col-sm-7 d-none d-md-block">
                            <!-- <button class="btn btn-primary float-right" type="button">
                                <svg class="c-icon">
                                    <use xlink:href="assets/icons/coreui/free-symbol-defs.svg#cui-cloud-download"></use>
                                </svg>
                            </button> -->
                            <div class="btn-group btn-group-toggle float-right mr-3" data-toggle="buttons">
                                <!-- <label class="btn btn-outline-secondary">
                                      <input id="option1" type="radio" name="options" autocomplete="off"> Day
                                    </label>
                                    <label class="btn btn-outline-secondary">
                                      <input id="option2" type="radio" name="options" autocomplete="off" checked=""> Month
                                    </label> -->
                                <label class="btn btn-outline-secondary active">
                                    <input id="option3" type="radio" name="options" autocomplete="off"> Year
                                </label>
                            </div>
                        </div>
                        <!-- /.col-->
                    </div>
                    <!-- /.row-->
                    <div class="c-chart-wrapper" style="height:300px;margin-top:40px;">
                        <canvas class="chart" id="main-chart" height="300"></canvas>
                    </div>
                </div>
                <!-- <div class="card-footer"> -->
                    <!-- <div class="row text-center"> -->
                        <!-- <div class="col-sm-12 col-md mb-sm-2 mb-0">
                            <div class="text-muted">Visits</div><strong>29.703 Users (40%)</strong>
                            <div class="progress progress-xs mt-2">
                                <div class="progress-bar bg-success" role="progressbar" style="width: 40%"
                                    aria-valuenow="40" aria-valuemin="0" aria-valuemax="100"></div>
                            </div>
                        </div> -->
                        <!-- <div class="col-sm-12 col-md mb-sm-2 mb-0">
                            <div class="text-muted">Unique</div><strong>24.093 Users (20%)</strong>
                            <div class="progress progress-xs mt-2">
                                <div class="progress-bar bg-info" role="progressbar" style="width: 20%" aria-valuenow="20"
                                    aria-valuemin="0" aria-valuemax="100"></div>
                            </div>
                        </div> -->
                       <!--  <div class="col-sm-12 col-md mb-sm-2 mb-0">
                            <div class="text-muted">Pageviews</div><strong>78.706 Views (60%)</strong>
                            <div class="progress progress-xs mt-2">
                                <div class="progress-bar bg-warning" role="progressbar" style="width: 60%"
                                    aria-valuenow="60" aria-valuemin="0" aria-valuemax="100"></div>
                            </div>
                        </div> -->
                        <!-- <div class="col-sm-12 col-md mb-sm-2 mb-0">
                            <div class="text-muted">New Users</div><strong>22.123 Users (80%)</strong>
                            <div class="progress progress-xs mt-2">
                                <div class="progress-bar bg-danger" role="progressbar" style="width: 80%" aria-valuenow="80"
                                    aria-valuemin="0" aria-valuemax="100"></div>
                            </div>
                        </div> -->
                        <!-- <div class="col-sm-12 col-md mb-sm-2 mb-0">
                            <div class="text-muted">Bounce Rate</div><strong>40.15%</strong>
                            <div class="progress progress-xs mt-2">
                                <div class="progress-bar" role="progressbar" style="width: 40%" aria-valuenow="40"
                                    aria-valuemin="0" aria-valuemax="100"></div>
                            </div>
                        </div> -->
                    <!-- </div> -->
                <!-- </div> -->
            </div>
            <!-- /.card-->
            <div class="row">
                <!-- <div class="col-sm-6 col-lg-4">
                              <div class="card">
                                <div class="card-header bg-facebook content-center">
                                  <svg class="c-icon c-icon-3xl text-white my-4">
                                    <use xlink:href="assets/icons/brands/brands-symbol-defs.svg#facebook-f"></use>
                                  </svg>
                                  <div class="c-chart-wrapper">
                                    <canvas id="social-box-chart-1" height="90"></canvas>
                                  </div>
                                </div>
                                <div class="card-body row text-center">
                                  <div class="col">
                                    <div class="text-value-xl">89k</div>
                                    <div class="text-uppercase text-muted small">friends</div>
                                  </div>
                                  <div class="c-vr"></div>
                                  <div class="col">
                                    <div class="text-value-xl">459</div>
                                    <div class="text-uppercase text-muted small">feeds</div>
                                  </div>
                                </div>
                              </div>
                            </div> -->
                <!-- /.col-->
                <!-- <div class="col-sm-6 col-lg-4">
                              <div class="card">
                                <div class="card-header bg-twitter content-center">
                                  <svg class="c-icon c-icon-3xl text-white my-4">
                                    <use xlink:href="assets/icons/brands/brands-symbol-defs.svg#twitter"></use>
                                  </svg>
                                  <div class="c-chart-wrapper">
                                    <canvas id="social-box-chart-2" height="90"></canvas>
                                  </div>
                                </div>
                                <div class="card-body row text-center">
                                  <div class="col">
                                    <div class="text-value-xl">973k</div>
                                    <div class="text-uppercase text-muted small">followers</div>
                                  </div>
                                  <div class="c-vr"></div>
                                  <div class="col">
                                    <div class="text-value-xl">1.792</div>
                                    <div class="text-uppercase text-muted small">tweets</div>
                                  </div>
                                </div>
                              </div>
                            </div> -->
                <!-- /.col-->
                <!-- <div class="col-sm-6 col-lg-4">
                              <div class="card">
                                <div class="card-header bg-linkedin content-center">
                                  <svg class="c-icon c-icon-3xl text-white my-4">
                                    <use xlink:href="assets/icons/brands/brands-symbol-defs.svg#linkedin"></use>
                                  </svg>
                                  <div class="c-chart-wrapper">
                                    <canvas id="social-box-chart-3" height="90"></canvas>
                                  </div>
                                </div>
                                <div class="card-body row text-center">
                               
                                    <div class="text-value-xl">500+</div>
                                    <div class="text-uppercase text-muted small">contacts</div>
                                  </div>
                                  <div class="c-vr"></div>
                                  <div class="col">
                                    <div class="text-value-xl">292</div>
                                    <div class="text-uppercase text-muted small">feeds</div>
                                  </div>
                                </div>
                              </div> -->
            </div>
            <!-- /.col-->
        </div>
        <!-- /.row-->
    </div>
    </div>
@endsection
@section('javascript')
    <script>
        var callcount = <?php echo json_encode($chartArrayCallTotal); ?>;    var days = <?php echo json_encode(
        $chartArrayCallDate); ?> //['M', 'T', 'W', 'T', 'F', 'S', 'S', 'M', 'T', 'W', 'T', 'F', 'S', 'S', 'M', 'T', 'W', 'T', 'F', 'S', 'S', 'M', 'T', 'W', 'T', 'F', 'S', 'S'];

    </script>
    <script src="{{ asset('js/Chart.min.js') }}"></script>
    <script src="{{ asset('js/coreui-chartjs.bundle.js') }}"></script>
    <script src="{{ asset('js/main.js') }}" defer></script>
@endsection
