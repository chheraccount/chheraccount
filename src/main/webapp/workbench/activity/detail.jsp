<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath() + "/";
%>
<!DOCTYPE html>
<html>
<head>
	<base href="<%=basePath%>">
<meta charset="UTF-8">

<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
<link href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css" rel="stylesheet" />
<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>

<script type="text/javascript">

	//默认情况下取消和保存按钮是隐藏的
	var cancelAndSaveBtnDefault = true;

	$(function(){

        $(".time").datetimepicker({
            language:  "zh-CN",
            format: "yyyy-mm-dd",//显示格式
            minView: "month",//设置只显示到月份
            autoclose: true,//选中自动关闭
            todayBtn: true, //显示今日按钮
            pickerPosition: "bottom-left"
        });

        $("#remark").focus(function(){
            if(cancelAndSaveBtnDefault){
                //设置remarkDiv的高度为130px
                $("#remarkDiv").css("height","130px");
                //显示
                $("#cancelAndSaveBtn").show("2000");
                cancelAndSaveBtnDefault = false;
            }
        });

        $("#cancelBtn").click(function(){
            //显示
            $("#cancelAndSaveBtn").hide();
            //设置remarkDiv的高度为130px
            $("#remarkDiv").css("height","90px");
            cancelAndSaveBtnDefault = true;
        });

        $(".remarkDiv").mouseover(function(){
            $(this).children("div").children("div").show();
        });

        $(".remarkDiv").mouseout(function(){
            $(this).children("div").children("div").hide();
        });

        $(".myHref").mouseover(function(){
            $(this).children("span").css("color","red");
        });

        $(".myHref").mouseout(function(){
            $(this).children("span").css("color","#E6E6E6");
        });

        //页面加载完毕后，展现该市场活动关联的备注信息列表
        showRemarkList();

        $("#remarkBody").on("mouseover",".remarkDiv",function(){
            $(this).children("div").children("div").show();
        })
        $("#remarkBody").on("mouseout",".remarkDiv",function(){
            $(this).children("div").children("div").hide();
        })

        //编辑市场活动信息
		$("#editActivityBtn").click(function (){


            $("#edit-id").val("${activity.id}");
            $("#edit-name").val("${activity.name}");
            $("#edit-startDate").val("${activity.startDate}");
            $("#edit-endDate").val("${activity.endDate}");
            $("#edit-cost").val("${activity.cost}");
            $("#edit-description").val("${activity.description}");

            //取得修改之前的原信息
            $.ajax({
                url:"workbench/activity/getUserList.do",
                type:"get",
                dataType:"json",
                success:function (data){

                    /*
                        data：{"uList":[{用户1},{2},..]}
                    */
                    //owner下拉框
                    var html = "";
                    $.each(data,function (i,n){
                        html += "<option value='"+n.id+"'>"+n.name+"</option>";
                    })
                    $("#edit-owner").html(html);

                    //修改框原信息
                }
            })
            $("#editActivityModal").modal("show");
		})

        //将修改的市场活动信息保存入数据库
        $("#updateActivityBtn").click(function (){

            var id = $("#edit-id").val();
            var owner = $("#edit-owner").val();
            var name = $("#edit-name").val();
            var startDate = $("#edit-startDate").val();
            var endDate = $("#edit-endDate").val();
            var cost = $("#edit-cost").val();
            var description = $("#edit-description").val();

            $.ajax({
                url:"workbench/activity/updateActivity.do",
                data:{
                    "id":id,
                    "owner":owner,
                    "name":name,
                    "startDate":startDate,
                    "endDate":endDate,
                    "cost":cost,
                    "description":description
                },
                type:"post",
                dataType:"json",
                success:function (data){
                    /*
                      data:{"success":true/false}
                     */
                    if(data.success){

                        window.location.href="workbench/activity/detail.do?id="+id;


                        //关闭修改操作的模态窗口
                        $("#editActivityModal").modal("hide");

                    }else{
                        alert("数据修改失败")
                    }
                }
            })
        })

        //修改备注信息并保存到数据库
        $("#updateActivityRemarkBtn").click(function (){

            var noteContent=$.trim($("#noteContent").val());
            var id=$("#remarkId").val();

            $.ajax({
                url:"workbench/activity/updateActivityRemark.do",
                data:{
                    "noteContent":noteContent,
                    "id":id
                },
                type:"post",
                dataType:"json",
                success:function (data){
                    /*
                        {"success":true/false,"ar":{备注}}
                     */
                    if(data.success){

                        //修改备注成功
                        //更新div中相应的信息，需要更新的内容有 noteContent，editTime，editBy
                        $("#e"+id).html(data.ar.noteContent);
                        $("#s"+id).html(data.ar.editTime+" 由"+data.ar.editBy);

                        //关闭模态窗口
                        $("#editRemarkModal").modal("hide");
                    }else{
                        alert("修改备注失败")
                    }
                }
            })



        })

		//将备注信息保存的数据库
		$("#saveActivityRemarkBtn").click(function (){

			var noteContent=$.trim($("#remark").val());
            if(noteContent.length==0){
                alert("备注不能为空")
            }else{
                $.ajax({
                    url:"workbench/activity/saveActivityRemark.do",
                    data:{
                        "noteContent":noteContent,
                        "activityId":"${activity.id}"
                    },
                    type:"post",
                    dataType:"json",
                    success:function (data){
                        /*
                            data:{"success":true/false}
                        */
                        if(data.success){

                            //textarea文本域中的信息清空掉
                            $("#remark").val("");

                            var html = "";

                            html += '<div id="'+data.ar.id+'" class="remarkDiv" style="height: 60px;">';
                            html += '<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">';
                            html += '<div style="position: relative; top: -40px; left: 40px;" >';
                            html += '<h5>'+data.ar.noteContent+'</h5>';
                            html += '<font color="gray">市场活动</font> <font color="gray">-</font> <b>${activity.name}</b> <small style="color: gray;"> '+(data.ar.createTime)+' 由'+(data.ar.createBy)+'</small>';
                            html += '<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">';
                            html += '<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #FF0000;"></span></a>';
                            html += '&nbsp;&nbsp;&nbsp;&nbsp;';
                            html += '<a class="myHref" href="javascript:void(0);" onclick="deleteRemark(\''+data.ar.id+'\')"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #FF0000;"></span></a>';
                            html += '</div>';
                            html += '</div>';
                            html += '</div>';

                            //在.page-header下方新增一个div
                            $(".page-header").after(html);

                        }else{
                            alert("备注保存失败")
                        }
                    }
                })
            }

		})

	});

    function showRemarkList(){
        //加载原始的备注信息
        $.ajax({
            url:"workbench/activity/getActivityRemark.do",
            data:{
                "activityId":"${activity.id}"
            },
            type:"get",
            dataType:"json",
            success:function (data){
                /*
                    data:{"activityRemarkList":[{备注1},{2},...]}

                 */
                var html = "";

                //生成备注信息
                $.each(data,function (i,n){

                    /*
						javascript:void(0);
							将超链接禁用，只能以触发事件的形式来操作
					 */

                    /*html += "<div class='"+n.id+"' class='remarkDiv' style='height: 60px;'>";
                    html += "<img title='zhangsan' src='image/user-thumbnail.png' style='width: 30px; height:30px;'>";
                    html += "<div style='position: relative; top: -40px; left: 40px;'>";
                    html += "<h5>"+n.noteContent+"</h5>";
                    html += "<font color='gray'>市场活动</font><font color='gray'>-</font><b>${activity.name}</b><small style='color: gray;'>";
                    html += (n.editFlag==0?n.createTime:n.editTime)+"由"+(n.editFlag==0?n.createBy:n.editBy)+"发出</small>";
                    html += "<div style='position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;'>";
                    html +=	"<a class='myHref' href='javascript:void(0);'onclick='deleteRemark("+n.id+")'><span class='glyphicon glyphicon-edit' style='font-size: 20px;color: #FF0000;'></span></a>";
                    html +=	"&nbsp;&nbsp;&nbsp;&nbsp;";
                    html +=	"<a class='myHref' href='javascript:void(0);'onclick='deleteRemark("+n.id+")'><span class='glyphicon glyphicon-remove' style='font-size: 20px;color: #FF0000;'></span></a>";
                    html +=	"</div></div></div>";*/

                    html += '<div id="'+n.id+'" class="remarkDiv" style="height: 60px;">';
                    html += '<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">';
                    html += '<div style="position: relative; top: -40px; left: 40px;" >';
                    html += '<h5 id="e'+n.id+'">'+n.noteContent+'</h5>';
                    html += '<font color="gray">市场活动</font> <font color="gray">-</font> <b>${a.name}</b> <small style="color: gray;" id="s'+n.id+'"> ';
                    html += (n.editFlag==0?n.createTime:n.editTime)+' 由'+(n.editFlag==0?n.createBy:n.editBy)+'</small>';
                    html += '<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">';
                    html += '<a class="myHref" href="javascript:void(0);" onclick="editRemark(\''+n.id+'\')"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #FF0000;"></span></a>';
                    html += '&nbsp;&nbsp;&nbsp;&nbsp;';
                    html += '<a class="myHref" href="javascript:void(0);" onclick="deleteRemark(\''+n.id+'\')"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #FF0000;"></span></a>';
                    html += '</div>';
                    html += '</div>';
                    html += '</div>';
                })

                $("#remarkDiv").before(html);

            }
        })
    }

    function deleteRemark(id) {

        $.ajax({

            url : "workbench/activity/deleteActivityRemark.do",
            data : {

                "id" : id

            },
            type : "post",
            dataType : "json",
            success : function (data) {

                /*
                    data
                        {"success":true/false}
                 */

                if(data.success){

                    //删除备注成功
                    //这种做法不行，记录使用的是before方法，每一次删除之后，页面上都会保留原有的数据
                    //showRemarkList();

                    //找到需要删除记录的div，将div移除掉 删除当前页面
                    $("#"+id).remove();


                }else{

                    alert("删除备注失败");

                }


            }

        })

    }

    //在模态窗口展现修改时原数据
    function editRemark(id) {

        //alert(id);

        //将模态窗口中，隐藏域中的id进行赋值
        $("#remarkId").val(id);

        //找到指定的存放备注信息的h5标签
        var noteContent = $("#e"+id).html();

        //将h5中展现出来的信息，赋予到修改操作模态窗口的文本域中
        $("#noteContent").val(noteContent);

        //以上信息处理完毕后，将修改备注的模态窗口打开
        $("#editRemarkModal").modal("show");

    }


</script>

</head>
<body>

	<!-- 修改市场活动备注的模态窗口 -->
	<div class="modal fade" id="editRemarkModal" role="dialog">
		<%-- 备注的id --%>
        <div class="modal-dialog" role="document" style="width: 40%;">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">
                        <span aria-hidden="true">×</span>
                    </button>
                    <h4 class="modal-title" id="activityMyModalLabel">修改备注</h4>
                </div>
                <div class="modal-body">
                    <input type="hidden" id="edit-id">
                    <form class="form-horizontal" role="form">
                        <div class="form-group">
                            <label for="edit-description" class="col-sm-2 control-label">内容</label>
                            <div class="col-sm-10" style="width: 81%;">
                                <textarea class="form-control" rows="3" id="noteContent"></textarea>
                            </div>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                    <button type="button" class="btn btn-primary" id="updateActivityRemarkBtn">更新</button>
                </div>
            </div>
        </div>
    </div>

    <!-- 修改市场活动的模态窗口 -->
    <div class="modal fade" id="editActivityModal" role="dialog">
        <input type="hidden" id="activityRemarkId">
        <div class="modal-dialog" role="document" style="width: 85%;">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">
                        <span aria-hidden="true">×</span>
                    </button>
                    <h4 class="modal-title" id="activityRemarkMyModalLabel">修改市场活动</h4>
                </div>
                <div class="modal-body">

                    <form class="form-horizontal" role="form">

                        <div class="form-group">
                            <label for="edit-owner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <select class="form-control" id="edit-owner">
                                </select>
                            </div>
                            <label for="edit-name" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="edit-name">
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="edit-startDate" class="col-sm-2 control-label time">开始日期</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control time" id="edit-startDate" readonly>
                            </div>
                            <label for="edit-endDate" class="col-sm-2 control-label time">结束日期</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control time" id="edit-endDate" readonly>
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="edit-cost" class="col-sm-2 control-label">成本</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="edit-cost">
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="edit-description" class="col-sm-2 control-label">描述</label>
                            <div class="col-sm-10" style="width: 81%;">
                                <textarea class="form-control" rows="3" id="edit-description"></textarea>
                            </div>
                        </div>

                    </form>

                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                    <button type="button" id="updateActivityBtn" class="btn btn-primary" >更新</button>
                </div>
            </div>
        </div>
    </div>

	<!-- 返回按钮 -->
	<div style="position: relative; top: 35px; left: 10px;">
		<a href="javascript:void(0);" onclick="window.history.back();"><span class="glyphicon glyphicon-arrow-left" style="font-size: 20px; color: #DDDDDD"></span></a>
	</div>

	<!-- 大标题 -->
	<div style="position: relative; left: 40px; top: -30px;">
		<div class="page-header">
			<h3>市场活动-${activity.name} <small>${activity.startDate} ~ ${activity.endDate}</small></h3>
		</div>
		<div style="position: relative; height: 50px; width: 250px;  top: -72px; left: 700px;">
			<button type="button" class="btn btn-default" id="editActivityBtn"><span class="glyphicon glyphicon-edit"></span> 编辑</button>
			<button type="button" class="btn btn-danger"><span class="glyphicon glyphicon-minus"></span> 删除</button>
		</div>
	</div>

	<!-- 详细信息 -->
	<div style="position: relative; top: -70px;">
		<div style="position: relative; left: 40px; height: 30px;">
			<div style="width: 300px; color: gray;">所有者</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${activity.owner}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">名称</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${activity.name}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>

		<div style="position: relative; left: 40px; height: 30px; top: 10px;">
			<div style="width: 300px; color: gray;">开始日期</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${activity.startDate}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">结束日期</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${activity.endDate}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 20px;">
			<div style="width: 300px; color: gray;">成本</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${activity.cost}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 30px;">
			<div style="width: 300px; color: gray;">创建者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${activity.createBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">${activity.createTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 40px;">
			<div style="width: 300px; color: gray;">修改者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${activity.editBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">${activity.editTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 50px;">
			<div style="width: 300px; color: gray;">描述</div>
			<div style="width: 630px;position: relative; left: 200px; top: -20px;">
				<b>${activity.description}</b>

			</div>
			<div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
	</div>

	<!-- 备注 -->
	<div style="position: relative; top: 30px; left: 40px;" id="remarkBody">
		<div class="page-header">
			<h4>备注</h4>
		</div>
		<%--<!-- 备注1 -->
		<div class="remarkDiv" style="height: 60px;">
			<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">
			<div style="position: relative; top: -40px; left: 40px;" >
				<h5>哎呦！</h5>
				<font color="gray">市场活动</font> <font color="gray">-</font> <b>发传单</b> <small style="color: gray;"> 2017-01-22 10:10:10 由zhangsan</small>
				<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #E6E6E6;"></span></a>
					&nbsp;&nbsp;&nbsp;&nbsp;
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #E6E6E6;"></span></a>
				</div>
			</div>
		</div>

		<!-- 备注2 -->
		<div class="remarkDiv" style="height: 60px;">
			<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">
			<div style="position: relative; top: -40px; left: 40px;" >
				<h5>呵呵！</h5>
				<font color="gray">市场活动</font> <font color="gray">-</font> <b>发传单</b> <small style="color: gray;"> 2017-01-22 10:20:10 由zhangsan</small>
				<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #E6E6E6;"></span></a>
					&nbsp;&nbsp;&nbsp;&nbsp;
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #E6E6E6;"></span></a>
				</div>
			</div>
		</div>
	--%>
		<div id="remarkDiv" style="background-color: #E6E6E6; width: 870px; height: 90px;">
			<form role="form" style="position: relative;top: 10px; left: 10px;">
				<textarea id="remark" class="form-control" style="width: 850px; resize : none;" rows="2"  placeholder="添加备注..."></textarea>
				<p id="cancelAndSaveBtn" style="position: relative;left: 737px; top: 10px; display: none;">
					<button id="cancelBtn" type="button" class="btn btn-default">取消</button>
					<button type="button" id="saveActivityRemarkBtn" class="btn btn-primary">保存</button>
				</p>
			</form>
		</div>
	</div>
	<div style="height: 200px;"></div>
</body>
</html>