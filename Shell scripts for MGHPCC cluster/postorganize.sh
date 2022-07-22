read -p "prefix: (obj idx): " obj idx
read -p "postfix (_xxx): " postfix

cd ./Synthesizer/results/"$obj"_"$idx"/
objdir="$PWD"

# group To Be Upload
echo "create directories"
tbuname=""$obj"_"$idx""$postfix""
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
cp ./log.txt "$tbudir"/"$obj""$idx"_log"$postfix".txt

echo "copying depth image 1-500, then rename heatmap folders"
cp -r ./1/fig/1280x720 "$tbudir1"/"$obj""$idx"_1280x720_1-500"$postfix"
mv ./1/cartHeat/cam1 ./1/cartHeat/"$obj""$idx"_cam1_1-500"$postfix"
mv ./1/cartHeat/cam2 ./1/cartHeat/"$obj""$idx"_cam2_1-500"$postfix"
mv ./1/cartHeat/cam3 ./1/cartHeat/"$obj""$idx"_cam3_1-500"$postfix"
mv ./1/cartHeat/cam4 ./1/cartHeat/"$obj""$idx"_cam4_1-500"$postfix"

echo "copying depth image 501-1000, then rename heatmap folders"
cp -r ./2/fig/1280x720 "$tbudir2"/"$obj""$idx"_1280x720_501-1000"$postfix"
mv ./2/cartHeat/cam1 ./2/cartHeat/"$obj""$idx"_cam1_501-1000"$postfix"
mv ./2/cartHeat/cam2 ./2/cartHeat/"$obj""$idx"_cam2_501-1000"$postfix"
mv ./2/cartHeat/cam3 ./2/cartHeat/"$obj""$idx"_cam3_501-1000"$postfix"
mv ./2/cartHeat/cam4 ./2/cartHeat/"$obj""$idx"_cam4_501-1000"$postfix"

echo "copying depth image 1001-1500, then rename heatmap folders"
cp -r ./3/fig/1280x720 "$tbudir3"/"$obj""$idx"_1280x720_1001-1500"$postfix"
mv ./3/cartHeat/cam1 ./3/cartHeat/"$obj""$idx"_cam1_1001-1500"$postfix"
mv ./3/cartHeat/cam2 ./3/cartHeat/"$obj""$idx"_cam2_1001-1500"$postfix"
mv ./3/cartHeat/cam3 ./3/cartHeat/"$obj""$idx"_cam3_1001-1500"$postfix"
mv ./3/cartHeat/cam4 ./3/cartHeat/"$obj""$idx"_cam4_1001-1500"$postfix"

echo "copying depth image 1501-2000, then rename heatmap folders"
cp -r ./4/fig/1280x720 "$tbudir4"/"$obj""$idx"_1280x720_1501-2000"$postfix"
mv ./4/cartHeat/cam1 ./4/cartHeat/"$obj""$idx"_cam1_1501-2000"$postfix"
mv ./4/cartHeat/cam2 ./4/cartHeat/"$obj""$idx"_cam2_1501-2000"$postfix"
mv ./4/cartHeat/cam3 ./4/cartHeat/"$obj""$idx"_cam3_1501-2000"$postfix"
mv ./4/cartHeat/cam4 ./4/cartHeat/"$obj""$idx"_cam4_1501-2000"$postfix"

echo "copying depth image 2001-2500, then rename heatmap folders"
cp -r ./5/fig/1280x720 "$tbudir5"/"$obj""$idx"_1280x720_2001-2500"$postfix"
mv ./5/cartHeat/cam1 ./5/cartHeat/"$obj""$idx"_cam1_2001-2500"$postfix"
mv ./5/cartHeat/cam2 ./5/cartHeat/"$obj""$idx"_cam2_2001-2500"$postfix"
mv ./5/cartHeat/cam3 ./5/cartHeat/"$obj""$idx"_cam3_2001-2500"$postfix"
mv ./5/cartHeat/cam4 ./5/cartHeat/"$obj""$idx"_cam4_2001-2500"$postfix"

# zip 
echo "zip heatmap folders"
cd ./1/cartHeat/
zip -r "$tbudir1"/"$obj""$idx"_cam1_1-500"$postfix".zip ./"$obj""$idx"_cam1_1-500"$postfix"
zip -r "$tbudir1"/"$obj""$idx"_cam2_1-500"$postfix".zip ./"$obj""$idx"_cam2_1-500"$postfix"
zip -r "$tbudir1"/"$obj""$idx"_cam3_1-500"$postfix".zip ./"$obj""$idx"_cam3_1-500"$postfix"
zip -r "$tbudir1"/"$obj""$idx"_cam4_1-500"$postfix".zip ./"$obj""$idx"_cam4_1-500"$postfix"

cd ../../2/cartHeat/
zip -r "$tbudir2"/"$obj""$idx"_cam1_501-1000"$postfix".zip ./"$obj""$idx"_cam1_501-1000"$postfix"
zip -r "$tbudir2"/"$obj""$idx"_cam2_501-1000"$postfix".zip ./"$obj""$idx"_cam2_501-1000"$postfix"
zip -r "$tbudir2"/"$obj""$idx"_cam3_501-1000"$postfix".zip ./"$obj""$idx"_cam3_501-1000"$postfix"
zip -r "$tbudir2"/"$obj""$idx"_cam4_501-1000"$postfix".zip ./"$obj""$idx"_cam4_501-1000"$postfix"

cd ../../3/cartHeat/
zip -r "$tbudir3"/"$obj""$idx"_cam1_1001-1500"$postfix".zip ./"$obj""$idx"_cam1_1001-1500"$postfix"
zip -r "$tbudir3"/"$obj""$idx"_cam2_1001-1500"$postfix".zip ./"$obj""$idx"_cam2_1001-1500"$postfix"
zip -r "$tbudir3"/"$obj""$idx"_cam3_1001-1500"$postfix".zip ./"$obj""$idx"_cam3_1001-1500"$postfix"
zip -r "$tbudir3"/"$obj""$idx"_cam4_1001-1500"$postfix".zip ./"$obj""$idx"_cam4_1001-1500"$postfix"

cd ../../4/cartHeat/
zip -r "$tbudir4"/"$obj""$idx"_cam1_1501-2000"$postfix".zip ./"$obj""$idx"_cam1_1501-2000"$postfix"
zip -r "$tbudir4"/"$obj""$idx"_cam2_1501-2000"$postfix".zip ./"$obj""$idx"_cam2_1501-2000"$postfix"
zip -r "$tbudir4"/"$obj""$idx"_cam3_1501-2000"$postfix".zip ./"$obj""$idx"_cam3_1501-2000"$postfix"
zip -r "$tbudir4"/"$obj""$idx"_cam4_1501-2000"$postfix".zip ./"$obj""$idx"_cam4_1501-2000"$postfix"

cd ../../5/cartHeat/
zip -r "$tbudir5"/"$obj""$idx"_cam1_2001-2500"$postfix".zip ./"$obj""$idx"_cam1_2001-2500"$postfix"
zip -r "$tbudir5"/"$obj""$idx"_cam2_2001-2500"$postfix".zip ./"$obj""$idx"_cam2_2001-2500"$postfix"
zip -r "$tbudir5"/"$obj""$idx"_cam3_2001-2500"$postfix".zip ./"$obj""$idx"_cam3_2001-2500"$postfix"
zip -r "$tbudir5"/"$obj""$idx"_cam4_2001-2500"$postfix".zip ./"$obj""$idx"_cam4_2001-2500"$postfix"

echo "Done"
# return to obj result folder
cd "$objdir"
# return to where the shell script runs
cd ../../../
