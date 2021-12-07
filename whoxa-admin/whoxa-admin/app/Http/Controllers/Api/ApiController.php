<?php
namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Providers\RouteServiceProvider;
use Illuminate\Foundation\Auth\AuthenticatesUsers;
use Illuminate\Http\Request;
use Kreait\Firebase\Auth as FirebaseAuth;
use Kreait\Firebase\Exception\FirebaseException;
use Illuminate\Validation\ValidationException;
use Auth;
use App\User;
use Illuminate\Support\Facades\Validator;
use Kreait\Firebase\Exception\InvalidArgumentException;
use Exception;
use Kreait\Firebase\Exception\Auth\EmailExists as FirebaseEmailExists;
use Kreait\Firebase\Exception\Auth\PhoneNumberExists as FirebaePhoneNumberExists;

class ApiController extends Controller
{
    use AuthenticatesUsers;
    protected $auth;
    public function __construct(FirebaseAuth $auth)
    {
        $this->middleware('guest')->except('logout');
        $this->auth = $auth;
    }

    public function login(Request $request)
    {
        $response['data'] = [];
        $email = $request->input('email');
        $password = $request->input('password');
        try {
            $signInResult = $this->auth->signInWithEmailAndPassword(
                $email,
                $password
            );
            $authData = $signInResult->data();

            $token = $authData['idToken'];
            $displayName = $authData['displayName'];
            $message = 'Login Successfully.';
            $data = [
                'token' => $token,
                'displayname' => $displayName,
                'message' => $message,
            ];
        } catch (\Kreait\Firebase\Exception\Auth\InvalidPassword | \Kreait\Firebase\Exception\InvalidArgumentException | \Kreait\Firebase\Auth\SignIn\FailedToSignIn $e) {
            $message = $e->getMessage();
            $data = ['message' => $message];
        }
        $response['data'] = $data;
        // $verifiedIdToken = $this->auth->verifyIdToken($token);
        // print_r($verifiedIdToken); die;
        echo json_encode($response);
    }

    public function createUser(Request $request)
    {
        $response['data'] = [];
        $database = app('firebase.database');
        $phonenumber = $request->input('phonenumber');
        $password = $request->input('password');
        $name = $request->input('name');
        try {
            $userProperties = [
                'phoneNumber' => $phonenumber,
                'emailVerified' => true,
                'password' => $password,
                'displayName' => $name,
                'disabled' => true,
            ];

            $createdUser = $this->auth->createUser($userProperties);
        } catch (FirebaePhoneNumberExists $e) {
            $message = $e->getMessage();
            $data = ['message' => $message];
        }
        $uid = $createdUser->uid;
        $token = $this->auth->createCustomToken($uid);
        $userData = $database->getReference('user')->set([
            'bio' => '',
            'countryCode' => '+91',
            'img' => '',
            'inChat' => '',
            'lastseen' => '',
            'location' => '',
            'mobile' => '',
            'name' => '',
            'token' => $this->auth->createCustomToken($createdUser->uid),
            'userId' => $createdUser->uid,
        ]);
        $response['data'] = $data;
        echo json_encode($response);
    }
}
