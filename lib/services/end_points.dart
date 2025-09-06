import 'package:tokshop/utils/configs.dart';

var rooms = "$baseUrl/rooms/";
var tokenPath = "$rooms/agora/rooom/generatetoken";
var rtmtoken = "$rooms/agora/rooom/rtmtoken";
var allEvents = "$rooms/events";
var myEvents = "$rooms/myevents";
var endedEvents = "$rooms/endedevents";
var roomById = "$rooms/room/";
var endedRoomById = "$rooms/ended/";
var record = "$rooms/record/";
var stoprecording = "$rooms/stoprecording/";
var eventById = "$rooms/event/";
var removeRoomProduct = "$rooms/rooms/product/";
var removeFromCurrentRoom = "$rooms/removecurrentroom/";
var roomNotication = "$rooms/rooms/roomnotifications/";
var createEventE = "$rooms/newevent/";
var addUserToRoom = "$rooms/user/add/";
var removeUserFromRoomUrl = "$rooms/user/remove/";
var removeSpeaker = "$rooms/speaker/remove/";
var removeInvitedSpeaker = "$rooms/invitedSpeaker/remove/";
var removeHost = "$rooms/host/remove/";
var removeUserFromRaisedHands = "$rooms/raisedhans/remove/";

var shippingprofiles = "$baseUrl/shipping/profiles";
var buylabel = "$shippingprofiles/buy/label";
var shippingprofilesestimate = "$shippingprofiles/estimate/rates";
var product = "$baseUrl/products/";
var giveaways = "$baseUrl/giveaways/";
var favorite = "$baseUrl/products/favorite";
var updatemany = "$baseUrl/products/update";
var products = "$product/products";
var stripesetup = "$baseUrl/stripe/setupitent";
var stripesavepaymentmethod = "$baseUrl/stripe/savepaymentmethod";
var taxestimate = "$baseUrl/stripe/tax/estimate";

var shop = "$baseUrl/shop/";
var import = "$baseUrl/import";
var importsp = "$baseUrl/import/shopify";
var updateproductimages = "${product}images/";
var singleproduct = "${product}product/";
var productreviews = "$baseUrl/products/review/";
var auth = "$baseUrl/auth";
var register = "$auth/signup";
var login = "$auth/login";
var settings = "$baseUrl/admin/app/settings";
var address = "$baseUrl/address/";
var addressForUser = "${address}all/";
var defaultaddress = "${address}default/address/";

var transactions = "$baseUrl/transactions";
var notifications = "$baseUrl/notifications";
var notificationsettigs = "$notifications/settings";
var category = "$baseUrl/category";
var followcategory = "$category/follow/";
var unfollowcategory = "$category/unfollow/";
var flutterwave = "$baseUrl/flutterwave";
var flutterwaveBanks = "$flutterwave/banks/";

var passwordResetEmail = "$baseUrl/sendResetPasswordEmail";
var resetPassword = "$baseUrl/resetPassword";

var singleproductqtycheck = "${singleproduct}product/qtycheck/";
var limit = "15";

var updateproduct = "${product}products/";
var wcdateproductcount = "${product}products/wc/count";

var user = "$baseUrl/users";
var tip = "$user/tip";
var friends = "$user/friends";
var shipping = "$baseUrl/shipping";
var approveeller = "$user/approveseller";
var userreviews = "$user/review/";
var paymentmethods = "$user/paymentmethod/";
var payoutmethods = "$user/payoutmethod/";
var userById = "$user/";
var usersummary = "$user/profile/summary/";
var userByAgoraId = "$user/agora/";
var checkcanreview = "$user/canreview/";
var userExistsByEmail = "$user/userexists/email";
var userFollowers = "$user/followers/";
var followersfollowing = "$user/followersfollowing/";
var userFollowing = "$user/following/";
var followUser = "$user/follow/";
var unFollowUser = "$user/unfollow/";
var editUser = "$user/";
var block = "$user/block/";
var unblock = "$user/unblock/";
var updateWallet = "$user/updateWallet/";
var upgradeUser = "$user/upgrade/";
var searchUsersByFirstName = "$user/search/";
var searchUsersByUserName = "$user/username/";
var followersfollowingsearch = "$user/followersfollowing/search/";
//use interests
var updateinterests = "$user/updateinterests";

var userProducts = "${product}get/all/";

var activities = "$baseUrl/activities";
var userActivities = "$activities/to/";
var addActivity = "$activities/";

var userTransactions = "$transactions/";
var updateTransactions = "$transactions/";

var orders = "$baseUrl/orders";
var dispute = "$orders/dispute";
var userOrders = "$orders/";
var allorders = "$orders/all/orders/";

var stripeBase = "https://api.stripe.com/v1";
var connectStripeBase = "$baseUrl/stripe/connect/";
var createIntentStripeUrl = "$baseUrl/stripe/createIntent/";

var stripeAccounts = "$baseUrl/stripe/banks";
var stripeAccountsDelete = "$baseUrl/stripe/accounts/delete";
var stripePayout = "$baseUrl/stripe/payouts";
var stripeBalance = "$baseUrl/stripe/balance";
var striperansactions = "$baseUrl/stripe/transactions";

var livekit = "$baseUrl/livekit";
var livekitToken = "$livekit/token";
var agora = "$baseUrl/stream/";
var auction = "$baseUrl/auction/";
var auctionbid = "$baseUrl/auction/bid";
var api = '$baseUrl/api/';
var allsettings = "${api}settings";
var allsettingsuppdate = "${api}settings/update";

var wcbase = "/wp-json/wc/v3/";
var wcproducts = "${wcbase}products?per_page=1";
var importwc = "$baseUrl/api/wc/app/import";

var REDIRECT_URI = "https://api.tokshoplive.com/api/shopify/auth";
var NONCE = "1234";
var SCOPES = "read_products,write_products,read_orders";
var API_KEY = 'a06ecb2c3436bb48ba29e61ed66c1985';
var importshopify =
    "https://c1kgna-xw.myshopify.com/admin/oauth/authorize?client_id=$API_KEY&scope=read_products,write_products&redirect_uri=$REDIRECT_URI&state=randomstring123";
