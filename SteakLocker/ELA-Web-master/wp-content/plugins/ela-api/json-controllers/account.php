<?php
/*
Controller name: ELA Login Form
Controller description: Handle login form submits
*/

use Parse\ParseException;
use Parse\ParseUser;

class JSON_API_Account_Controller
{
    public function login()
    {
        nocache_headers();

        $method = 'post';//strtolower($_SERVER['REQUEST_METHOD']);
        $func   = 'login_form_method_'. $method;

        if (method_exists($this, $func)) {
            return  $this->$func();
        }

        return [];
    }


    public function logout()
    {
        $currentUser = ParseUser::getCurrentUser();
        if ($currentUser) {
            $currentUser->logOut();
        }
        wp_safe_redirect('/');
        exit();
    }


    public function update()
    {
        nocache_headers();

        $method = 'post';
        $func   = 'account_form_method_'. $method;

        if (method_exists($this, $func)) {
            return  $this->$func();
        }

        return [];
    }


    public function unlink()
    {
        global $json_api;
        $elaUserId = $_REQUEST['u'];
        ela_unlink_user($elaUserId);
        wp_safe_redirect('/account');
        exit();
    }

    protected function login_form_method_post()
    {
        /** @var JSON_API $json_api */
        global $json_api;

        $response = [];

        $email = $_REQUEST['email'];
        $pass  = $_REQUEST['pass'];
        try {
            $currentUser = ParseUser::logIn($email, $pass);
            ela_link_user($currentUser);

            $response['url'] = '/account';
        }
        catch (ParseException $e) {
            $json_api->error('Your email or password are incorrect.');
        }
        catch (Exception $e) {
            $json_api->error('An error occured while logging in');
        }

        return $response;
    }


    protected function account_form_method_post()
    {
        /** @var JSON_API $json_api */
        global $json_api;

        $response = [];

        $name  = $_REQUEST['name'];
        $email = $_REQUEST['email'];
        $pass  = $_REQUEST['password'];

        try {

            $currentUser = ParseUser::getCurrentUser();
            if ($currentUser) {
                $changed = false;
                if ($name) {
                    $currentUser->set('name', $name);
                    $changed = true;
                }
                if ($email) {
                    $currentUser->setEmail($email);
                    $changed = true;
                }
                if ($pass) {
                    $currentUser->setPassword($pass);
                    $changed = true;
                }

                if ($changed) {
                    $currentUser->save();
                }
            }
        }
        catch (ParseException $e) {
            $json_api->error('An error occured (1001)');
        }
        catch (Exception $e) {
            $json_api->error('An error occured (1002)');
        }

        return $response;
    }
}