/*
This file is part of GameHub.
Copyright (C) 2018 Anatoliy Kashkin

GameHub is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

GameHub is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with GameHub.  If not, see <https://www.gnu.org/licenses/>.
*/

using Gtk;
using Gdk;
using Granite;
using GLib;
using Gee;
using GameHub.Utils;
using GameHub.UI.Widgets;

using GameHub.Data;
using GameHub.Data.Sources.Steam;

namespace GameHub.UI.Dialogs
{
	public class CompatRunDialog: Dialog
	{
		public Game game { get; construct; }

		private Box content;
		private Label title_label;
		private CompatToolOptions opts_list;

		private CompatToolPicker compat_tool_picker;

		public CompatRunDialog(Game game)
		{
			Object(game: game, transient_for: Windows.MainWindow.instance, resizable: false, title: _("Run with compatibility layer"));
		}

		construct
		{
			get_style_context().add_class("rounded");
			get_style_context().add_class(Gtk.STYLE_CLASS_FLAT);

			modal = true;

			var hbox = new Box(Orientation.HORIZONTAL, 8);
			hbox.margin_start = hbox.margin_end = 5;

			content = new Box(Orientation.VERTICAL, 0);

			var icon = new AutoSizeImage();
			icon.set_constraint(48, 48, 1);
			icon.set_size_request(48, 48);

			title_label = new Label(game.name);
			title_label.margin_start = 8;
			title_label.halign = Align.START;
			title_label.valign = Align.START;
			title_label.hexpand = true;
			title_label.get_style_context().add_class(Granite.STYLE_CLASS_H2_LABEL);
			content.add(title_label);

			compat_tool_picker = new CompatToolPicker(game, false);
			compat_tool_picker.margin_start = 4;
			content.add(compat_tool_picker);

			opts_list = new CompatToolOptions(game, compat_tool_picker, false);

			content.add(opts_list);

			Utils.load_image.begin(icon, game.icon, "icon");

			response.connect((source, response_id) => {
				switch(response_id)
				{
					case ResponseType.ACCEPT:
						run_with_compat();
						destroy();
						break;
				}
			});

			var run_btn = add_button(_("Run"), ResponseType.ACCEPT);
			run_btn.get_style_context().add_class(Gtk.STYLE_CLASS_SUGGESTED_ACTION);
			run_btn.grab_default();

			hbox.add(icon);
			hbox.add(content);

			get_content_area().add(hbox);
			get_content_area().set_size_request(340, 96);
			show_all();
		}

		private void run_with_compat()
		{
			if(compat_tool_picker == null || compat_tool_picker.selected == null) return;

			compat_tool_picker.selected.run.begin(game);

			opts_list.save_options();
		}
	}
}
