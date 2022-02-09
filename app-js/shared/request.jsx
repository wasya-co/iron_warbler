import axios from "axios";
import config from "config";

const settings = {
  baseURL: config.apiOrigin
}

export default axios.create(settings);