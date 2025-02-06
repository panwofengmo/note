#!/bin/sh

cd /root/redis_envt/

lua daily_silver_detail.lua >> daily_silver_detail.log
lua daily_silver_channel_detail.lua >> daily_silver_channel_detail.log
