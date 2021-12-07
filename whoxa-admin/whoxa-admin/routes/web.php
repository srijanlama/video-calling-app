<?php

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "web" middleware group. Now create something great!
|
*/

Route::get('/', function () {
    return view('welcome');
});
Auth::routes();
Route::group(['middleware' => ['auth']], function () {
    Route::get('/home', 'HomeController@index')->name('home');
    //Route::get('home', function () {return view('dashboard.homepage');});
    Route::resource('users', 'UsersController');
    Route::resource('roles', 'RolesController');
    Route::resource('group', 'GroupController');
    Route::post('users/block/{id}', 'UsersController@block')->name(
        'users.block'
    );
    Route::put('users/update/{id}', 'UsersController@update')->name(
        'users_update'
    );
    Route::get('block-users', 'UsersController@blockUser')->name('block-users');
    Route::get('group-users', 'GroupController@index')->name('group-users');
    Route::post('group/destroy/{id}', 'GroupController@destroy')->name('group-destroy');
    Route::post('group/memberDestroy/{id}', 'GroupController@memberDestroy')->name('group-memberDestroy');
    
    Route::get('admob-list', 'SettingController@admobList')->name('admob-list');
    
    Route::get('status_on_off_ajax', 'SettingController@status_on_off_ajax');
    
    Route::get('admob-list/edit', 'SettingController@edit');
    Route::get('admob-list/update', 'SettingController@update');
    
    Route::get('setting', 'SettingController@setting')->name('setting');
    
    Route::get('notification', 'NotificationController@index')->name(
        'notification'
    );
    Route::post('add-notification', 'NotificationController@store')->name(
        'add-notification'
    );
    Route::post('notification/destroy/{id}', 'NotificationController@destroy')->name(
        'notification-destroy'
    );
});
