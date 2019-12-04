# OpenFaaS PHP7 HTTP template

This repository contains the PHP7 (currently 7.4) HTTP template, it uses RoadRunner [RoadRunner](https://roadrunner.dev/) to handle the interaction between the watchdog
and that of the PHP function.

RoadRunner communicates with the PHP function utilising PSR-7 so your handler *must* return a PSR-7 response, it's also worth noting that
if you _echo_ or _print_ that'll cause an error as that uses STDOUT - you'll want another debugging strategy.

This is not production ready, lots of testing is required.
Note: Tweak RR workers and evaluate performance