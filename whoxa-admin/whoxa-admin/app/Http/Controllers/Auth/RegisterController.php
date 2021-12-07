<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Providers\RouteServiceProvider;
use App\User;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Foundation\Auth\RegistersUsers;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Kreait\Firebase\Auth as FirebaseAuth;
use Kreait\Firebase\Exception\FirebaseException;
use Illuminate\Validation\ValidationException;


class RegisterController extends Controller
{
    use RegistersUsers;
    protected $auth;
    protected $redirectTo = RouteServiceProvider::HOME;

    public function __construct(FirebaseAuth $auth)
    {
        $this->middleware('guest');
        $this->auth = $auth;
    }

    protected function validator(array $data)
    {
        return Validator::make($data, [
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'string', 'email', 'max:255'],
            'password' => ['required', 'string', 'min:8', 'confirmed'],
        ]);
    }
    protected function register(Request $request)
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

        return redirect()->route('login');
    }

}
