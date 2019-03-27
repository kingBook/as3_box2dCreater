package  {
	import com.bit101.components.*;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author kingBook
	 * 2015/8/28 16:27
	 */
	public class UI {
		private var _shell:Shell;
		private var _parent:Sprite;
		private var _importBox:ComboBox;//输入地址栏
		private var _browseInputBtn:PushButton;//输入浏览按钮
		private var _imgPathBox:ComboBox;//img输出路径栏
		private var _imgPathBrowseBtn:PushButton;//img输出路径浏览按钮
		private var _xmlPathBox:ComboBox;//xml输出路径栏
		private var _xmlPathBrowseBtn:PushButton;//xml输出路径浏览按钮
		private var _exportBtn:PushButton;//发布按钮
		private var _textArea:TextArea;//打印消息框
		private var _mcKeyInputText:InputText;//
		private var _mcIdMinInputText:InputText;//
		private var _mcIdMaxInputText:InputText;
		private var _customKeyInputText:InputText;
		private var _frameMcInputText:InputText;
		public function UI(parent:Sprite, shell:Shell) {
			_parent = parent;
			_shell = shell;
			
			//swf
			new Label(_parent, 5, 5, "swf/png：");
			_importBox = new ComboBox(_parent, 60, 5, "无");
			_importBox.width = 400;
			_browseInputBtn = new PushButton(_parent, 465, 5, "浏览");
			_browseInputBtn.width = 35;
			//导出
			_exportBtn = new PushButton(_parent, 510, 10, "导出");
			_exportBtn.width = 60;
			_exportBtn.height = 30;
			
			//xml
			new Label(_parent, 5, 30, "xml位置:");
			_xmlPathBox = new ComboBox(_parent, 60, 30, "无");
			_xmlPathBox.width = 400;
			_xmlPathBrowseBtn = new PushButton(_parent, 465, 30, "浏览");
			_xmlPathBrowseBtn.width = 35;
			
			new Label(_parent,5,60,"元件前缀:");
			_mcKeyInputText = new InputText(_parent, 65, 60, "");
			_mcKeyInputText.width = 70;
			new Label(_parent, 140, 60, "ID:");
			_mcIdMinInputText = new InputText(_parent, 160, 60);
			_mcIdMinInputText.width = 25;
			new Label(_parent, 185, 60, "-");
			_mcIdMaxInputText = new InputText(_parent, 195, 60);
			_mcIdMaxInputText.width = 25;
			new Label(_parent, 225, 60, "自定义名(','隔开):");
			_customKeyInputText = new InputText(_parent, 340, 60);
			_customKeyInputText.width = 225;
			
			new Label(_parent,5,85,"多帧元件(多个','隔开):");
			_frameMcInputText = new InputText(_parent,140,85);
			_frameMcInputText.width = 200;
				
			_textArea = new TextArea(_parent, 10, 140);
			_textArea.width = 560;
			_textArea.height = 250;
			_textArea.html = true;
			
		}
		
		public function get importBox():ComboBox { return _importBox; }
		
		public function get browseInputBtn():PushButton { return _browseInputBtn; }
		
		public function get imgPathBrowseBtn():PushButton { return _imgPathBrowseBtn; }
		
		public function get xmlPathBrowseBtn():PushButton { return _xmlPathBrowseBtn; }
		
		public function get imgPathBox():ComboBox { return _imgPathBox; }
		
		public function get xmlPathBox():ComboBox { return _xmlPathBox; }
		
		public function get exportBtn():PushButton { return _exportBtn; }
		
		public function get textArea():TextArea { return _textArea; }
		
		public function get mcKeyInputText():InputText { return _mcKeyInputText; }
		
		public function get mcIdMinInputText():InputText{ return _mcIdMinInputText; }
		
		public function get mcIdMaxInputText():InputText { return _mcIdMaxInputText; }
		
		public function get customKeyInputText():InputText { return _customKeyInputText; }
		
		public function get frameMcInputText():InputText { return _frameMcInputText; }
		
		
		
	}

}