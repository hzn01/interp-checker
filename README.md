v1.0.0
setup for tickrate 100 servers in mind.
and:
sv_client_min_interp_ratio 1.0
sv_client_max_interp_ratio 1.0

v1.1.0
now also checks interp_ratio and updaterate of server- and client-side to properly read and calculate lerp/interp.
reports correct (server-side) value back to the client.
works with any server tickrate now.
