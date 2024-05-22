


class BoardCreatorState extends funkin.editors.ui.UIState {
	public function create() {
		_HX_SUPER__create();

		import flixel.FlxSprite;
		import flixel.FlxG;
		import funkin.editors.ui.UIState;
		import funkin.editors.ui.IUIFocusable;
		import funkin.editors.ui.UITopMenu;
		import funkin.editors.ui.UISliceSprite;
		import funkin.editors.ui.UIButton;
		import funkin.editors.ui.UICheckbox;
		import funkin.editors.ui.UIWarningSubstate;
		import funkin.editors.ui.UITextBox;

		import flixel.tweens.FlxTween;

		FlxG.mouse.visible = true;

		FlxG.camera.setFilters([]);
		FlxG.mouse.useSystemCursor = FlxG.mouse.visible = true;

		var bg = new FlxSprite().makeSolid(FlxG.width, FlxG.height, 0xFF444444);
		bg.updateHitbox();
		bg.scrollFactor.set();
		add(bg);

		add(new UITopMenu([
			{
				label: "File",
				childs: [
					{
						label: "New"
					},
					{
						label: "Open"
					},
					{
						label: "Save"
					},
					{
						label: "Save As..."
					},
					null,
					{
						label: "Exit",
						onSelect: (t) -> {FlxG.switchState(new ModState("SelectState"));}
					}
				]
			},
			{
				label: "Edit"
			},
			{
				label: "View"
			},
			{
				label: "Help"
			}
		]));

		add(new UICheckbox(10, 40, "Test unchecked", false));
		add(new UICheckbox(10, 70, "Test checked", true));
		add(new UIButton(10, 100, "Test button", function() {
			trace("Hello, World!");
		}, 130, 32));
	
	
		add(new UITextBox(10, 220, ""));

	
	}

	public function update(elapsed:Float) {
		_HX_SUPER__update(elapsed);
		if(FlxG.keys.justPressed.ESCAPE)
			FlxG.switchState(new ModState("SelectState"));
		if (FlxG.mouse.justReleasedRight) {
			openContextMenu([
				{
					label: "Test 1",
					onSelect: function(t) {
						trace("Test 1 clicked");
					}
				},
				{
					label: "Test 2",
					onSelect: function(t) {
						trace("Test 2 clicked");
					}
				},
				{
					label: "Test 3",
					childs: [
						{
							label: "Test 4",
							onSelect: function(t) {
								trace("Test 4 clicked");
							}
						}
					]
				}
			]);
		}
	}
}