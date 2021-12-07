<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Kreait\Firebase;
use Kreait\Firebase\Database;
use Carbon\Carbon;
use Carbon\CarbonPeriod;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging;
use Kreait\Firebase\Storage;
use Kreait\Firebase\Factory;
use Kreait\Firebase\firestore;
use Illuminate\Routing\UrlGenerator;
use Illuminate\Support\Facades\URL;


class NotificationController extends Controller
{
    /**
     * Create a new controller instance.
     *
     * @return void
     */
     protected $database;
    public function __construct()
    {
        $this->middleware('auth');
        $this->database = app('firebase.database');
    }

    /**
     * Show the application dashboard.
     *
     * @return \Illuminate\Contracts\Support\Renderable
     */
    public function index()
    {
        
        $pushNotifications = $this->database
            ->getReference('pushNotification')
            ->getvalue();
        $pushNotifications = array_reverse($pushNotifications);
        return view(
            'dashboard.general.notification',
            compact('pushNotifications')
        );
    }

    public function store(Request $request)
    {
        $messaging = app('firebase.messaging');
        
        $title = $request->title;
        $notification = $request->pushnotis;
        $date = Carbon::now()->timestamp;
        
        $image = $request->file('image'); //image file from frontend 
        
        if(!empty($image)){
            $name = $image->getClientOriginalName();
            $firebase_storage_path = 'notificationImage/';  
            $localfolder = public_path('firebase-temp-uploads') .'/';
            $extension = $image->getClientOriginalExtension();  
            $file      = $name;  
            if ($image->move($localfolder, $file)) {  
                $uploadedfile = fopen($localfolder.$file, 'r');
                app('firebase.storage')->getBucket()->upload($uploadedfile, ['name' => $firebase_storage_path . $name]);  
                //will remove from local laravel folder
                //unlink($localfolder . $file);  
                echo 'success';  
            }
            $imageUrl = url('/').'/public/firebase-temp-uploads/'. $name;    
        }else{
            $imageUrl = '';
        }
        
        $notificationData = [
            'title' => $title,
            'notification' => $notification,
            'date' => $date,
        ];
        $postRef = $this->database
            ->getReference('pushNotification')
            ->push($notificationData);
        $postKey = $postRef->getKey();

        /**************Send Notification******************/
        $tokens = $this->database->getReference('user')->getvalue();
        $arrayToken = [];
        foreach ($tokens as $token) {
            if (isset($token['token']) && !empty($token['token'])) {
                $arrayToken[] = $token['token'];
            }
        }
        $spiltTokens = array_chunk($arrayToken, 500);
        foreach ($spiltTokens as $spiltToken) {
            //$deviceToken = ['eoCzdjmETKS6gEwwrKVmI7:APA91bGbgrdg6dpbdPwAhUHn-zWA-acEjESXOH2xYYaE543wCyKxKILHLAE07rRsxx3HqIMgtPLfCLQ9no7h8UOGPf40vV8lXzSvHV--aec-Mabs5qtpr77BagmBJ4VALL9HnseIaCHQ','eX0iI634TG-x94Q-eZMZBH:APA91bErYTop0xFBAcvCH1oSJTMbSaQRr8fRHij_elte6FDQaznvxXTeNew99ErT-xriX733CacW71qn9jTXa_VKh8PgxQ2AWtsTAusxAyvALXlNhidLhGOk_V7zeSpPTfuyfgJ7wWyY'];
            $deviceToken = $spiltToken;
            $message = CloudMessage::new()->withNotification([
                'title' => $title,
                'body' => $notification,
                'image' => $imageUrl
            ]);
        }
        $report = $messaging->sendMulticast($message, $deviceToken);
        /**************Send Notification******************/
        return redirect('notification');
    }
    
    public function destroy($id)
    {
        $this->database->getReference('pushNotification/' . $id)->remove();
        return redirect('/notification');
    }
}
