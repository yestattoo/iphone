/*
The MIT License (MIT)
Copyright (c) 2014 Nigel Brady
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE. */

import UIKit

class MultipleChoiceController: UITableViewController {
  
  var header: String = ""
  var footer: String = ""
  
  var allowMultipleSelections: Bool = false
  var maximumAllowedSelections: Int?
  
  var choices: [NSObject]?
  var selectedItems = [NSObject]()
  
  var delegate: MultipleChoiceControllerDelegate?
  
  var doneButton: UIBarButtonItem?
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }
  
  override init(style: UITableViewStyle) {
    super.init(style: UITableViewStyle.Grouped)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override func viewDidLoad() {
    if allowMultipleSelections{
      self.doneButton =
        UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done,
          target: self, action: "finishSelection")
      
      self.navigationItem.rightBarButtonItem = doneButton
      doneButton?.enabled = !selectedItems.isEmpty
    }
    
    self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
    self.tableView.dataSource = self
    self.tableView.delegate = self
    self.tableView.reloadData()
  }
  
  func finishSelection(){
    delegate?.multipleChoiceController(self, didSelectItems: selectedItems)
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return choices!.count
  }
  
  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return header
  }
  
  override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    return footer
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    let cell =
    tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
    
    let choice = self.choices![indexPath.row]
    
    cell.textLabel?.text = choice.description
    
    cell.accessoryType =
      selectedItems.contains(choice) ?
        UITableViewCellAccessoryType.Checkmark : UITableViewCellAccessoryType.None
    
    return cell
  }
  
  override func tableView(tableView: UITableView,
    didSelectRowAtIndexPath indexPath: NSIndexPath) {
      
      let choice = choices![indexPath.row]
      
      if let index = selectedItems.indexOf(choice){
        selectedItems.removeAtIndex(index)
      } else if shouldAllowSelection() {
        selectedItems.append(choice)
      }
      
      tableView.reloadRowsAtIndexPaths([indexPath],
        withRowAnimation: UITableViewRowAnimation.Automatic)
      
      if allowMultipleSelections{
        doneButton?.enabled = !selectedItems.isEmpty
      } else {
        finishSelection()
      }
  }
  
  func shouldAllowSelection() -> Bool{
    if !allowMultipleSelections{
      return true
    } else if allowMultipleSelections && maximumAllowedSelections == nil{
      return true
    } else {
      return selectedItems.count < maximumAllowedSelections!
    }
  }
  
  
  override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    var footerView : UIView?
    
    footerView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 50))
    footerView?.backgroundColor = self.view.backgroundColor
    
    let dunamicButton = UIButton(type: UIButtonType.System)
    dunamicButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
    dunamicButton.setTitle("Submit", forState: UIControlState.Normal)
    dunamicButton.frame = CGRectMake(0, 0, 100, 50)
    dunamicButton.addTarget(self, action: "buttonTouched:", forControlEvents: UIControlEvents.TouchUpInside)
    footerView?.addSubview(dunamicButton)
    
    return footerView
  }
  
  func buttonTouched(sender:UIButton!){
    self.dismissViewControllerAnimated(true) { () -> Void in
      
      
    }
  }
  
  override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 50.0
  }
  
}

protocol MultipleChoiceControllerDelegate{
  func multipleChoiceController(controller: MultipleChoiceController,
    didSelectItems items: [NSObject])
}