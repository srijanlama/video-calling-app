<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Kreait\Firebase;
use Kreait\Firebase\Database;
use Carbon\Carbon;
use Carbon\CarbonPeriod;

class HomeController extends Controller
{
    /**
     * Create a new controller instance.
     *
     * @return void
     */
    public function __construct()
    {
        $this->middleware('auth');
    }

    /**
     * Show the application dashboard.
     *
     * @return \Illuminate\Contracts\Support\Renderable
     */
    public function index()
    {
        $database = app('firebase.database');
        $broadcast = $database->getReference('broadcast');
        $broadcastCount = $broadcast->getSnapshot()->numChildren();
        
        $group = $database->getReference('group');
        $groupCount = $group->getSnapshot()->numChildren();
        
        $statistics = $database->getReference('call_history')->getvalue();
        $videoCount = 0;
        $voiceCount = 0;
        if (!empty($statistics)) {
            foreach ($statistics as $key => $statistic) {
                if ($statistic['callType'] == 'voice') {
                    $voiceCount = ++$voiceCount;
                }
                if ($statistic['callType'] == 'video') {
                    $videoCount = ++$videoCount;
                }
                if (isset($statistic['time'])) {
                    $callDate = date('Y-m-d', $statistic['time'] / 1000);
                    $timeArray[] = [
                        'date' => $callDate,
                        'type' => $statistic['callType'],
                    ];
                }
            }
        }

        $new_array = [];
        if (!empty($timeArray)) {
            foreach ($timeArray as $v) {
                $date_key = strtotime($v['date']);
                if (!isset($new_array[$date_key])) {
                    $new_array[$date_key] = array_merge($v, ['total' => 0]);
                }
                $new_array[$date_key]['total']++;
            }
            ksort($new_array);
            $new_array = array_values($new_array);

            foreach ($new_array as $dateArray) {
                $chartArrayCallTotal[] = $dateArray['total'];
                $chartArrayCallDate[] = date_format(
                    date_create($dateArray['date']),
                    'd M Y'
                );
            }
        }
        return view(
            'dashboard.homepage',
            compact(
                'videoCount',
                'voiceCount',
                'broadcastCount',
                'groupCount',
                'chartArrayCallTotal',
                'chartArrayCallDate'
            )
        );
    }
}
