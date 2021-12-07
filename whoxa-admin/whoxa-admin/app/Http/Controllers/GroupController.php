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

class GroupController extends Controller
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

    public function index()
    {
        $group = $this->database->getReference('group');
        $groupLists = $group->getSnapshot()->getvalue();
        return view('dashboard.group.groupUsersList', compact('groupLists'));
    }

    public function create()
    {
        //return view('dashboard.admin.userCreateForm');
    }
    /**
     * Display the specified resource.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function show($id)
    {
        $group = $this->database->getReference('group/' . $id)->getValue();
        $user = $this->database
            ->getReference('user/' . $group['createrId'])
            ->getValue();
        return view(
            'dashboard.group.groupShow',
            compact('group', 'user', 'id')
        );
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
        return view('dashboard.admin.userEditForm', compact('user'));
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
        $validatedData = $request->validate([
            'name' => 'required|min:1|max:256',
            'email' => 'required|email|max:256',
        ]);
        $user = $this->auth->getUser($id);
        $user->name = $request->input('name');
        $user->email = $request->input('email');
        $properties = [
            'displayName' => $request->input('name'),
            'email' => $request->input('email'),
        ];
        $updatedUser = $this->auth->updateUser($id, $properties);
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
        $user = $this->database->getReference('group/' . $id)->remove();
        return redirect()->route('group.index');
    }

    public function memberDestroy($id)
    {
        $gname = $_POST['gname'];
        $user = $this->database->getReference('group/' . $gname . '/name/'.$id)
            ->remove();
        return redirect()->route('group.index');
    }
}
