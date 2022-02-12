

<div class="flex-row">
  <div class="form-group">
    <label for="stock_watch_action">Action</label>
    <select name="stock_watch[action]" id="stock_watch_action"><option value="NONE">NONE</option>
      <option value="EMAIL">EMAIL</option>
      <option value="SMS">SMS</option>
    </select>
  </div>
  <div class="form-group">
    <label for="stock_watch_profile">Profile</label>
    <select name="stock_watch[profile]" id="stock_watch_profile">
      <option value=""></option>
      <option value="piousbox@gmail.com">piousbox@gmail.com</option>
    </select>
  </div>
  <div class="form-group">
    <label class="control-label">When</label>
    <input class="form-control" placeholder="ticker" type="text" name="stock_watch[ticker]" id="stock_watch_ticker" />
  </div>
  <div class="form-group">
    <label class="control-label">Price</label>
    <select name="stock_watch[direction]" id="stock_watch_direction">
      <option value="ABOVE">ABOVE</option>
      <option value="BELOW">BELOW</option>
    </select>
  </div>
  <div class="form-group">
    <label class="control-label">$</label>
    <input step="0.01" placeholder="0.01" type="number" name="stock_watch[price]" id="stock_watch_price" />
  </div>
  <div class="form-group">
    <input type="submit" name="commit" value=">" class="btn blue" data-disable-with=">" />
  </div>
</div>