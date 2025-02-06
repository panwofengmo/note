#!/bin/sh

cd /root/redis_envt/

lua daily_diamond_detail.lua >> daily_diamond_detail.log
lua daily_diamond_channel_detail.lua >> daily_diamond_channel_detail.log
