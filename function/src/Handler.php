<?php

namespace App;

use Zend\Diactoros\Response;

/**
 * Class Handler
 * @package App
 */
class Handler
{
    /**
     * @param $data
     * @return
     */
    public function handle($data) {
        $response = new Response();
        $response->getBody()->write('{"message": "Hello world!"}');
        $response = $response->withHeader('Content-Type', 'application/json');
        return $response;
    }
}
