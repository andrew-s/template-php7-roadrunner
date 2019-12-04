<?php
/**
 * @var Goridge\RelayInterface $relay
 */
use Spiral\Goridge;
use Spiral\RoadRunner;
use Spiral\Debug;

ini_set('display_errors', 'stderr');
require 'vendor/autoload.php';

// Requires Function composer's autoload
if (file_exists('function/vendor/autoload.php')) {
    require('function/vendor/autoload.php');
}

$worker = new RoadRunner\Worker(new Goridge\StreamRelay(STDIN, STDOUT));
$psr7 = new RoadRunner\PSR7Client($worker);

// temp debug
$dumper = new Debug\Dumper();
$dumper->setRenderer(Debug\Dumper::ERROR_LOG, new Debug\Renderer\ConsoleRenderer());

while ($req = $psr7->acceptRequest()) {
    try {
        $response = (new App\Handler())->handle($req);
        $dumper->dump($req->getUri(), Debug\Dumper::ERROR_LOG); // debug
        $psr7->respond($response);
    } catch (\Throwable $e) {
        $psr7->getWorker()->error((string)$e);
    }
}
