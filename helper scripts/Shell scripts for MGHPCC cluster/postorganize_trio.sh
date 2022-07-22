read -p "prefix: separate with spaces (obj1 idx1 obj2 idx2 obj3 idx3): " obj1 idx1 obj2 idx2 obj3 idx3
read -p "postfix: include'_' (_xxx): " postfix

prefix=""$obj1""$idx1"-"$obj2""$idx2"-"$obj3""$idx3""
cd ./Synthesizer/results/"$prefix"/
objdir="$PWD"

# group To Be Upload
echo "create directories"
tbuname=""$prefix""$postfix""
tbudir=""$objdir"/"$tbuname""
tbudir1=""$tbudir"/1-500"
tbudir2=""$tbudir"/501-1000"
tbudir3=""$tbudir"/1001-1500"
tbudir4=""$tbudir"/1501-2000"
tbudir5=""$tbudir"/2001-2500"
mkdir "$tbudir"
mkdir "$tbudir1"
mkdir "$tbudir2"
mkdir "$tbudir3"
mkdir "$tbudir4"
mkdir "$tbudir5"

# rename
echo "rename and copy images"
#cp ./log.txt "$tbudir"/"$obj""$idx"_log"$postfix".txt

echo "copying depth image 1-500" #, then rename heatmap folders"
# cp -r ./1/label "$tbudir1"/"$prefix"_label_1-500"$postfix"
cp -r ./1/fig/1280x720 "$tbudir1"/"$prefix"_1280x720_1-500"$postfix"
#mv ./1/cartHeat/cam1 ./1/cartHeat/"$prefix"_cam1_1-500"$postfix"
#mv ./1/cartHeat/cam2 ./1/cartHeat/"$prefix"_cam2_1-500"$postfix"
#mv ./1/cartHeat/cam3 ./1/cartHeat/"$prefix"_cam3_1-500"$postfix"
#mv ./1/cartHeat/cam4 ./1/cartHeat/"$prefix"_cam4_1-500"$postfix"

echo "copying depth image 501-1000" #, then rename heatmap folders"
#cp -r ./2/label "$tbudir2"/"$prefix"_label_501-1000"$postfix"
cp -r ./2/fig/1280x720 "$tbudir2"/"$prefix"_1280x720_501-1000"$postfix"
#mv ./2/cartHeat/cam1 ./2/cartHeat/"$prefix"_cam1_501-1000"$postfix"
#mv ./2/cartHeat/cam2 ./2/cartHeat/"$prefix"_cam2_501-1000"$postfix"
#mv ./2/cartHeat/cam3 ./2/cartHeat/"$prefix"_cam3_501-1000"$postfix"
#mv ./2/cartHeat/cam4 ./2/cartHeat/"$prefix"_cam4_501-1000"$postfix"

echo "copying depth image 1001-1500" #, then rename heatmap folders"
#cp -r ./3/label "$tbudir3"/"$prefix"_label_1001-1500"$postfix"
cp -r ./3/fig/1280x720 "$tbudir3"/"$prefix"_1280x720_1001-1500"$postfix"
#mv ./3/cartHeat/cam1 ./3/cartHeat/"$prefix"_cam1_1001-1500"$postfix"
#mv ./3/cartHeat/cam2 ./3/cartHeat/"$prefix"_cam2_1001-1500"$postfix"
#mv ./3/cartHeat/cam3 ./3/cartHeat/"$prefix"_cam3_1001-1500"$postfix"
#mv ./3/cartHeat/cam4 ./3/cartHeat/"$prefix"_cam4_1001-1500"$postfix"

echo "copying depth image 1501-2000" #, then rename heatmap folders"
#cp -r ./4/label "$tbudir4"/"$prefix"_label_1501-2000"$postfix"
cp -r ./4/fig/1280x720 "$tbudir4"/"$prefix"_1280x720_1501-2000"$postfix"
#mv ./4/cartHeat/cam1 ./4/cartHeat/"$prefix"_cam1_1501-2000"$postfix"
#mv ./4/cartHeat/cam2 ./4/cartHeat/"$prefix"_cam2_1501-2000"$postfix"
#mv ./4/cartHeat/cam3 ./4/cartHeat/"$prefix"_cam3_1501-2000"$postfix"
#mv ./4/cartHeat/cam4 ./4/cartHeat/"$prefix"_cam4_1501-2000"$postfix"

echo "copying depth image 2001-2500" #, then rename heatmap folders"
#cp -r ./5/label "$tbudir5"/"$prefix"_label_2001-2500"$postfix"
cp -r ./5/fig/1280x720 "$tbudir5"/"$prefix"_1280x720_2001-2500"$postfix"
#mv ./5/cartHeat/cam1 ./5/cartHeat/"$prefix"_cam1_2001-2500"$postfix"
#mv ./5/cartHeat/cam2 ./5/cartHeat/"$prefix"_cam2_2001-2500"$postfix"
#mv ./5/cartHeat/cam3 ./5/cartHeat/"$prefix"_cam3_2001-2500"$postfix"
#mv ./5/cartHeat/cam4 ./5/cartHeat/"$prefix"_cam4_2001-2500"$postfix"

# zip 
echo "zip labels and heatmap folders"
cd ./1/
zip -r "$tbudir1"/"$prefix"_label_1-500"$postfix".zip ./label
cd ./cartHeat/
zip -r "$tbudir1"/"$prefix"_cam1_1-500"$postfix".zip ./cam1
zip -r "$tbudir1"/"$prefix"_cam2_1-500"$postfix".zip ./cam2
zip -r "$tbudir1"/"$prefix"_cam3_1-500"$postfix".zip ./cam3
zip -r "$tbudir1"/"$prefix"_cam4_1-500"$postfix".zip ./cam4

cd ../../2/
zip -r "$tbudir2"/"$prefix"_label_501-1000"$postfix".zip ./label
cd ./cartHeat/
zip -r "$tbudir2"/"$prefix"_cam1_501-1000"$postfix".zip ./cam1
zip -r "$tbudir2"/"$prefix"_cam2_501-1000"$postfix".zip ./cam2
zip -r "$tbudir2"/"$prefix"_cam3_501-1000"$postfix".zip ./cam3
zip -r "$tbudir2"/"$prefix"_cam4_501-1000"$postfix".zip ./cam4

cd ../../3/
zip -r "$tbudir3"/"$prefix"_label_1001-1500"$postfix".zip ./label
cd ./cartHeat/
zip -r "$tbudir3"/"$prefix"_cam1_1001-1500"$postfix".zip ./cam1
zip -r "$tbudir3"/"$prefix"_cam2_1001-1500"$postfix".zip ./cam2
zip -r "$tbudir3"/"$prefix"_cam3_1001-1500"$postfix".zip ./cam3
zip -r "$tbudir3"/"$prefix"_cam4_1001-1500"$postfix".zip ./cam4

cd ../../4/
zip -r "$tbudir4"/"$prefix"_label_1501-2000"$postfix".zip ./label
cd ./cartHeat/
zip -r "$tbudir4"/"$prefix"_cam1_1501-2000"$postfix".zip ./cam1
zip -r "$tbudir4"/"$prefix"_cam2_1501-2000"$postfix".zip ./cam2
zip -r "$tbudir4"/"$prefix"_cam3_1501-2000"$postfix".zip ./cam3
zip -r "$tbudir4"/"$prefix"_cam4_1501-2000"$postfix".zip ./cam4

cd ../../5/
zip -r "$tbudir5"/"$prefix"_label_2001-2500"$postfix".zip ./label
cd ./cartHeat/
zip -r "$tbudir5"/"$prefix"_cam1_2001-2500"$postfix".zip ./cam1
zip -r "$tbudir5"/"$prefix"_cam2_2001-2500"$postfix".zip ./cam2
zip -r "$tbudir5"/"$prefix"_cam3_2001-2500"$postfix".zip ./cam3
zip -r "$tbudir5"/"$prefix"_cam4_2001-2500"$postfix".zip ./cam4

echo "Done"
# return to obj result folder
cd "$objdir"
# return to where the shell script runs
cd ../../../
