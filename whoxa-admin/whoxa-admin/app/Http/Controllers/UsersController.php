<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\User;
use Kreait\Firebase;
use Kreait\Firebase\Factory;
use Kreait\Firebase\ServiceAccount;
use Kreait\Firebase\Database;
use Kreait\Firebase\Auth as FirebaseAuth;
use Kreait\Firebase\Auth\UserRecord;
use Kreait\Auth\Request\UpdateUser;
use Kreait\Firebase\Exception\Messaging\InvalidMessage;
use Illuminate\Validation\ValidationException;
use Kreait\Firebase\Exception\InvalidArgumentException;
use Kreait\Firebase\Exception\Auth\EmailExists;
use Illuminate\Foundation\Auth\RegistersUsers;
use Illuminate\Support\Facades\Validator;
use Kreait\Firebase\Exception\FirebaseException;

class UsersController extends Controller
{
    /**
     * Create a new controller instance.
     *
     * @return void
     *
     */
    protected $auth;
    protected $database;
    public function __construct(FirebaseAuth $auth)
    {
        $this->middleware('auth');
        $this->auth = $auth;
        $this->database = app('firebase.database');
    }

    protected function validator(array $data)
    {
        return Validator::make($data, [
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'string', 'email', 'max:255'],
            'password' => ['required', 'string', 'min:8', 'confirmed'],
        ]);
    }
    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index()
    {
        $database = app('firebase.database');
        $users = $this->auth->listUsers();
        $you = auth()->user();
        $userListArray = [];
        foreach ($users as $user) {
            $userData = $database
                ->getReference('user/' . $user->uid . '/name')
                ->getvalue();
            if (!empty($userData)) {
                $name = $userData;
            } else {
                $name = '';
            }
            $userListArray[] = [
                'uid' => $user->uid,
                'phoneNumber' => $user->phoneNumber,
                'name' => $name,
                'disabled'=>$user->disabled
            ];
        }
        return view('dashboard.admin.usersList', compact('userListArray', 'you'));
    }

    public function create()
    {
        return view('dashboard.admin.userCreateForm');
    }
    
    public function store(Request $request)
    {
        try {
            $mobile_no = $request->mobile_no;
            if (!empty($mobile_no)) {
                return redirect()->route('users.index');
            }
        } catch (Exception $e) {
            return view('dashboard.admin.userCreateForm');
        }
    }
    public function store1(Request $request)
    {
        try {
            $this->validator($request->all())->validate();
            $userProperties = [
                'email' => $request->input('email'),
                'emailVerified' => true,
                'password' => $request->input('password'),
                'displayName' => $request->input('name'),
                'disabled' => true,
            ];
            $createdUser = $this->auth->createUser($userProperties);
        } catch (FirebaseException $e) {
            throw ValidationException::withMessages([
                'email' => $e->getMessage(),
            ]);
        }
        $request->session()->flash('message', 'Successfully created note');
        return redirect()->route('users.index');
    }
    /**
     * Display the specified resource.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function show($id)
    {
        $user = $this->auth->getUser($id);
        $userName = $this->database
                ->getReference('user/' . $user->uid . '/name')
                ->getvalue();
        $phoneNumber = $user->phoneNumber;
        return view('dashboard.admin.userShow', compact('phoneNumber','userName'));
    }

    /**
     * Show the form for editing the specified resource.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function edit($id)
    {
        $user = $this->auth->getUser($id);
        $userName = $this->database
                ->getReference('user/' . $user->uid . '/name')
                ->getvalue();
        $phoneNumber = $user->phoneNumber;
        return view('dashboard.admin.userEditForm', compact('phoneNumber','userName','id'));
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request, $id)
    {
        $phoneNumber = $request->phoneNumber;
        $name = $request->name;
        $uid = $id;
        $properties = [
            'phoneNumber' =>$phoneNumber
        ];
        $updatedPhone = $this->auth->updateUser($uid, $properties);
        $updatesUser = [
            'user/'.$uid.'/name' => $request->name,
        ];
        $this->database->getReference()->update($updatesUser);

        $request->session()->flash('message', 'Successfully updated user');
        return redirect()->route('users.index');
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function destroy($id)
    {
        $user = $this->auth->getUser($id);
        if ($user) {
            $this->auth->deleteUser($id);
        }
        return redirect()->route('users.index');
    }

    public function block($id)
    {
        $user = $this->auth->getUser($id);
        if (!empty($user) && $user->disabled) {
            $block = $this->auth->enableUser($id);
        } else {
            $block = $this->auth->disableUser($id);
        }
        return redirect()->route('block-users');
    }

    public function blockUser()
    {
        $users = $this->auth->listUsers();
        $userListArray = [];
        foreach ($users as $user) {
            $userData = $this->database->getReference('user/' . $user->uid . '/name')->getvalue();
            if (!empty($userData)) {
                $name = $userData;
            } else {
                $name = '';
            }
            $userListArray[] = [
                'uid' => $user->uid,
                'phoneNumber' => $user->phoneNumber,
                'name' => $name,
                'disabled'=>$user->disabled
            ];
        }
        //dd($userListArray);
        
        return view('dashboard.admin.blockUsersList', compact('userListArray'));
    }
}
