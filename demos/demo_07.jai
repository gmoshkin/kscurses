demo_07 :: () {
	ticks := 0;
	last_key : Key;
	last_event : Event;
	stop_main := false;
	events_count := 0;

	draw :: () #expand {
		ks_mode_reset();
		ks_clear_screen();
		ks_print(.{0, 0}, make_graphics_mode(foreground = .BLACK, background = .BRIGHT_GREEN), "ticks = %", ticks);
		ks_print(.{0, 1}, make_graphics_mode(foreground = .BLACK, background = .BRIGHT_GREEN), "key =   %", last_key);
		ks_print(.{0, 2}, make_graphics_mode(foreground = .BLACK, background = .BRIGHT_GREEN), "size =  %", terminal_state.size);
		ks_print(.{0, 3}, make_graphics_mode(foreground = .BLACK, background = .BRIGHT_GREEN), "event = %", last_event);
	}

	#if MULTITHREAD {
		__event_handler.data = *(struct{_ticks : type_of(*ticks); _stop_main : type_of(*stop_main); _last_key : type_of(*last_key); _last_event : type_of(*last_event); _events_count : type_of(*events_count);}).{*ticks, *stop_main, *last_key, *last_event, *events_count};
		__event_handler.proc = (e : Event, __data : *void) {
			using cast(*struct{_ticks : type_of(*ticks); _stop_main : type_of(*stop_main); _last_key : type_of(*last_key); _last_event : type_of(*last_event); _events_count : type_of(*events_count);}) __data;
			if e.type == {
				case .KEY;
				<<_last_key = e.key;
				case .TICK;
				<<_ticks += 1;
			}
			<<_last_event = e;
			if e.type == .KEY && e.key == .ESCAPE {
				<<_stop_main = true;
			}			
		};
		use_ks_curses();
		use_events();
		while !stop_main {
			if wait_and_process_events() {
				draw();
				reset_temporary_storage();
			}
		}
	} else {
		use_ks_curses();
		use_default_winch_handler();
		while !stop_main {
			draw();
			reset_temporary_storage();
			key := ks_getch();
			if key == .ESCAPE stop_main = true;
			if key != .READ_ERROR last_key = key;
		}
	}
}
#scope_file
MULTITHREAD :: true;