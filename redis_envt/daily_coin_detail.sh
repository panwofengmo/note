#!/bin/sh

cd /root/redis_envt/

lua daily_coin_detail.lua >> daily_coin_detail.log
lua daily_coin_channel_detail.lua >> daily_coin_channel_detail.log
