#!/bin/sh
# The layer rule: dependencies point down — screens → models → repositories → the world.
# Prints NOTHING when the rule holds. Run it before every commit.
cd "$(dirname "$0")/.." || exit 1

# 1. http only in core/api and in *_repository.dart
grep -rl "package:http" lib/ | grep -v -e core/api -e _repository.dart

# 2. no Flutter UI (material) in models, repositories or core/api
grep -rl "package:flutter/material" lib/ | grep -e _model.dart -e _repository.dart -e core/api

exit 0
